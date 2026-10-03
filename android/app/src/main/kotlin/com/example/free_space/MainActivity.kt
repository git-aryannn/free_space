package com.example.free_space

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.StatFs
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.Settings
import android.webkit.MimeTypeMap
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

class MainActivity : FlutterActivity() {
    private data class MediaStoreItem(val uri: Uri, val isMedia: Boolean)

    companion object {
        private const val REQUEST_TRASH = 1001
        private const val REQUEST_MEDIA_PERMISSION = 1002
        private const val REQUEST_SCAN_FOLDER = 1003
        private const val REQUEST_ALL_FILES_ACCESS = 1004
        private const val REQUEST_NOTIFICATION_PERMISSION = 1005
        private const val TRASH_BATCH_SIZE = 2000
        private const val APP_BIN_DIRECTORY = "Free Space Bin"
        private const val SCAN_ROOT_PREFERENCES = "free_space_scan"
        private const val SCAN_ROOT_KEY = "authorized_tree_uri"
    }

    private var pendingFolderPickerResult: MethodChannel.Result? = null
    private var pendingFolderPickerReturnsList = false
    private var pendingAllFilesAccessResult: MethodChannel.Result? = null
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null
    private var pendingTrashResult: MethodChannel.Result? = null
    private var pendingTrashItems: Map<String, Uri> = emptyMap()
    private var pendingTrashBatches: List<Map<String, Uri>> = emptyList()
    private var pendingFileTrashPaths: List<String> = emptyList()
    private val completedTrashItems = linkedMapOf<String, String>()
    private var pendingAppBinRestoreRollback: List<Pair<String, String>> = emptyList()
    private var observerManager: ObserverManager? = null
    private var pendingAppBinDeletePaths: List<String> = emptyList()
    private var pendingRestore = false
    private var pendingPermanentDeletePaths: List<String>? = null
    private var pendingMediaPaths: List<String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_SCAN_FOLDER) {
            val result = pendingFolderPickerResult ?: return
            pendingFolderPickerResult = null
            if (resultCode != RESULT_OK || data?.data == null) {
                pendingFolderPickerReturnsList = false
                result.success(null)
                return
            }
            val uri = data.data!!
            try {
                val flags = data.flags and
                    (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                contentResolver.takePersistableUriPermission(uri, flags)
                getSharedPreferences(SCAN_ROOT_PREFERENCES, MODE_PRIVATE)
                    .edit()
                    .putString(SCAN_ROOT_KEY, uri.toString())
                    .apply()
                result.success(
                    if (pendingFolderPickerReturnsList) listOf(uri.toString())
                    else uri.toString()
                )
            } catch (error: Exception) {
                result.error("FOLDER_ACCESS_FAILED", "Could not access the selected folder.", error.message)
            } finally {
                pendingFolderPickerReturnsList = false
            }
            return
        }
        if (requestCode == REQUEST_ALL_FILES_ACCESS) {
            val result = pendingAllFilesAccessResult ?: return
            pendingAllFilesAccessResult = null
            result.success(Environment.isExternalStorageManager())
            return
        }
        if (requestCode != REQUEST_TRASH) return

        val result = pendingTrashResult ?: return
        if (resultCode == RESULT_OK) {
            if (pendingRestore) {
                pendingAppBinRestoreRollback = emptyList()
                clearTrashRequest()
                result.success(true)
            } else if (pendingPermanentDeletePaths != null) {
                pendingTrashItems.forEach { (path, uri) ->
                    completedTrashItems[path] = uri.toString()
                }
                pendingTrashItems = emptyMap()
                val nextBatch = pendingTrashBatches.firstOrNull()
                if (nextBatch != null) {
                    pendingTrashBatches = pendingTrashBatches.drop(1)
                    launchDeleteBatch(nextBatch)
                } else {
                    val deletedPaths = completedTrashItems.keys.toList() +
                        deleteAppBinFiles(pendingAppBinDeletePaths)
                    clearTrashRequest()
                    result.success(deletedPaths)
                }
            } else {
                pendingTrashItems.forEach { (path, uri) ->
                    completedTrashItems[path] = uri.toString()
                }
                pendingTrashItems = emptyMap()
                val nextBatch = pendingTrashBatches.firstOrNull()
                if (nextBatch != null) {
                    pendingTrashBatches = pendingTrashBatches.drop(1)
                    launchTrashBatch(nextBatch)
                } else {
                    val movedItems = completedTrashItems.toMutableMap()
                    movedItems.putAll(movePathsIntoAppBin(pendingFileTrashPaths))
                    clearTrashRequest()
                    result.success(movedItems)
                }
            }
        } else {
            if (pendingRestore) rollbackAppBinRestores()
            if (pendingPermanentDeletePaths != null) {
                val deletedPaths = completedTrashItems.keys.toList()
                clearTrashRequest()
                if (deletedPaths.isNotEmpty()) {
                    result.success(deletedPaths)
                } else {
                    result.error(
                        "DELETE_CANCELLED",
                        "Android System Trash deletion was cancelled.",
                        null
                    )
                }
                return
            }
            val movedItems = completedTrashItems.toMap()
            clearTrashRequest()
            if (movedItems.isNotEmpty()) {
                result.success(movedItems)
            } else {
                result.error("TRASH_CANCELLED", "System Trash action was cancelled.", null)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATION_PERMISSION) {
            val result = pendingNotificationPermissionResult ?: return
            pendingNotificationPermissionResult = null
            result.success(
                Build.VERSION.SDK_INT < 33 ||
                    grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
            )
            return
        }
        if (requestCode != REQUEST_MEDIA_PERMISSION) return

        val result = pendingTrashResult ?: return
        val paths = pendingMediaPaths ?: return
        if (grantResults.isEmpty() || grantResults.any { it != PackageManager.PERMISSION_GRANTED }) {
            pendingTrashResult = null
            pendingMediaPaths = null
            result.error(
                "MEDIA_PERMISSION_DENIED",
                "Media access is required before Android can move this item to Trash.",
                null
            )
        } else {
            pendingMediaPaths = null
            requestSystemTrash(paths, result)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.freespace.app/platform"
        )
        observerManager = ObserverManager(channel)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getStorageInfo" -> getStorageInfo(result)
                "hasNotificationPermission" -> result.success(
                    Build.VERSION.SDK_INT < 33 ||
                        ContextCompat.checkSelfPermission(
                            this,
                            android.Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                )
                "requestNotificationPermission" -> requestNotificationPermission(result)
                "hasAllFilesAccess" -> result.success(
                    Build.VERSION.SDK_INT < Build.VERSION_CODES.R ||
                        Environment.isExternalStorageManager()
                )
                "requestAllFilesAccess" -> requestAllFilesAccess(result)
                "startFileObserver" -> {
                    val paths = call.argument<List<String>>("paths") ?: emptyList()
                    observerManager?.startObserving(paths)
                    result.success(true)
                }
                "getDownloadsPath" -> result.success(
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_DOWNLOADS
                    ).absolutePath
                )
                "getExternalStorageRootPath" -> result.success(
                    Environment.getExternalStorageDirectory().absolutePath
                )
                "setScanRoot" -> {
                    val rootPath = call.argument<String>("path")
                    getSharedPreferences(SCAN_ROOT_PREFERENCES, MODE_PRIVATE)
                        .edit().putString(SCAN_ROOT_KEY, rootPath).apply()
                    result.success(true)
                }
                "getScanRoot" -> result.success(
                    getSharedPreferences(SCAN_ROOT_PREFERENCES, MODE_PRIVATE)
                        .getString(SCAN_ROOT_KEY, null)
                )
                "getScanRootPath" -> result.success(getScanRootDisplayPath())
                "selectScanRoot" -> openFolderPicker(result, returnsList = false)
                "selectScanItems" -> openFolderPicker(result, returnsList = true)
                "scanDocumentTree" -> {
                    val treeUri = call.argument<String>("treeUri")
                    if (treeUri.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "A selected folder is required.", null)
                    } else {
                        Thread {
                            try {
                                val scan = scanDocumentTree(Uri.parse(treeUri))
                                runOnUiThread { result.success(scan) }
                            } catch (error: Exception) {
                                runOnUiThread {
                                    result.error("SCAN_FAILED", "Could not scan the selected folder.", error.message)
                                }
                            }
                        }.start()
                    }
                }
                "showInFileManager" -> showItem(call.argument("path"), result)
                "moveItemsToSystemTrash" -> moveItemsToTrash(call.argument("paths"), result)
                "restoreItemsFromSystemTrash" ->
                    restoreItemsFromTrash(call.argument("items"), result)
                "permanentlyDeleteItemsFromSystemTrash" ->
                    permanentlyDeleteItemsFromTrash(call.argument("paths"), result)
                "listSystemTrashItems" -> listSystemTrashItems(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getStorageInfo(result: MethodChannel.Result) {
        try {
            val stats = StatFs(Environment.getExternalStorageDirectory().absolutePath)
            val totalBytes = stats.totalBytes
            val freeBytes = stats.availableBytes.coerceAtMost(totalBytes)
            result.success(
                mapOf(
                    "totalBytes" to totalBytes,
                    "usedBytes" to (totalBytes - freeBytes).coerceAtLeast(0L),
                    "freeBytes" to freeBytes
                )
            )
        } catch (error: Exception) {
            result.error("STORAGE_INFO_FAILED", "Could not read device storage information.", error.message)
        }
    }

    private fun requestAllFilesAccess(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R ||
            Environment.isExternalStorageManager()
        ) {
            result.success(true)
            return
        }
        if (pendingAllFilesAccessResult != null) {
            result.error(
                "PERMISSION_REQUEST_IN_PROGRESS",
                "An all-files access request is already open.",
                null
            )
            return
        }
        pendingAllFilesAccessResult = result
        try {
            val intent = Intent(
                Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, REQUEST_ALL_FILES_ACCESS)
        } catch (error: Exception) {
            pendingAllFilesAccessResult = null
            result.error(
                "ALL_FILES_SETTINGS_UNAVAILABLE",
                "Could not open Android's all-files access settings.",
                error.message
            )
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33 ||
            ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (pendingNotificationPermissionResult != null) {
            result.error(
                "PERMISSION_REQUEST_IN_PROGRESS",
                "A notification permission request is already open.",
                null
            )
            return
        }
        pendingNotificationPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATION_PERMISSION
        )
    }

    private fun openFolderPicker(result: MethodChannel.Result, returnsList: Boolean) {
        if (pendingFolderPickerResult != null) {
            result.error("PICKER_IN_PROGRESS", "A folder picker is already open.", null)
            return
        }
        pendingFolderPickerResult = result
        pendingFolderPickerReturnsList = returnsList
        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val savedUri = getSharedPreferences(
                        SCAN_ROOT_PREFERENCES,
                        MODE_PRIVATE
                    ).getString(SCAN_ROOT_KEY, null)?.let(Uri::parse)
                    val initialUri = savedUri ?: DocumentsContract.buildTreeDocumentUri(
                        "com.android.externalstorage.documents",
                        "primary:"
                    )
                    putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
                }
            }
            startActivityForResult(intent, REQUEST_SCAN_FOLDER)
        } catch (error: Exception) {
            pendingFolderPickerResult = null
            pendingFolderPickerReturnsList = false
            result.error("FOLDER_PICKER_FAILED", "Could not open the folder picker.", error.message)
        }
    }

    private fun scanDocumentTree(treeUri: Uri): Map<String, Any> {
        if (!DocumentsContract.isTreeUri(treeUri)) {
            throw IllegalArgumentException("The selected location is not a folder.")
        }
        val rootDocumentId = DocumentsContract.getTreeDocumentId(treeUri)
        val pendingDocumentIds = ArrayDeque<String>()
        pendingDocumentIds.add(rootDocumentId)
        val items = mutableListOf<Map<String, Any>>()
        var inaccessibleDirectories = 0
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED
        )

        while (pendingDocumentIds.isNotEmpty()) {
            val parentId = pendingDocumentIds.removeLast()
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
            try {
                contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                    val idColumn = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                    val nameColumn = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                    val mimeColumn = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
                    val sizeColumn = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_SIZE)
                    val modifiedColumn = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_LAST_MODIFIED)
                    while (cursor.moveToNext()) {
                        val documentId = cursor.getString(idColumn)
                        val mimeType = cursor.getString(mimeColumn)
                        if (mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
                            pendingDocumentIds.add(documentId)
                        } else {
                            val name = cursor.getString(nameColumn) ?: continue
                            val sizeBytes = if (sizeColumn >= 0 && !cursor.isNull(sizeColumn)) {
                                cursor.getLong(sizeColumn).coerceAtLeast(0L)
                            } else {
                                0L
                            }
                            val modifiedAt = if (modifiedColumn >= 0 && !cursor.isNull(modifiedColumn)) {
                                cursor.getLong(modifiedColumn).coerceAtLeast(0L)
                            } else {
                                0L
                            }
                            items += mapOf(
                                "name" to name,
                                "path" to documentIdToPath(documentId),
                                "sizeBytes" to sizeBytes,
                                "lastModified" to modifiedAt
                            )
                        }
                    }
                }
            } catch (error: Exception) {
                if (parentId == rootDocumentId) throw error
                inaccessibleDirectories++
            }
        }
        return mapOf("items" to items, "inaccessibleDirectories" to inaccessibleDirectories)
    }

    private fun documentIdToPath(documentId: String): String {
        val volumeId = documentId.substringBefore(':')
        val relativePath = documentId.substringAfter(':', "")
        val volumePath = if (volumeId.equals("primary", ignoreCase = true)) {
            Environment.getExternalStorageDirectory().absolutePath
        } else {
            "/storage/$volumeId"
        }
        return File(volumePath, relativePath).absolutePath
    }

    private fun getScanRootDisplayPath(): String? {
        val savedUri = getSharedPreferences(SCAN_ROOT_PREFERENCES, MODE_PRIVATE)
            .getString(SCAN_ROOT_KEY, null) ?: return null
        return try {
            documentIdToPath(
                DocumentsContract.getTreeDocumentId(Uri.parse(savedUri))
            )
        } catch (_: Exception) {
            savedUri
        }
    }

    private fun showItem(path: String?, result: MethodChannel.Result) {
        if (path == null) {
            result.error("INVALID_ARGUMENT", "Path is required.", null)
            return
        }
        val file = File(path)
        val existingUri = Uri.parse(path)
        if (existingUri.scheme != "content" && !file.exists()) {
            result.error("ITEM_NOT_FOUND", "The selected item no longer exists.", path)
            return
        }
        try {
            val uri = if (existingUri.scheme == "content") {
                existingUri
            } else {
                FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            }
            val mimeType = contentResolver.getType(uri)
                ?: MimeTypeMap.getSingleton()
                    .getMimeTypeFromExtension(file.extension.lowercase())
                ?: if (file.isDirectory) "vnd.android.document/directory"
                else "application/octet-stream"
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(intent, "Open with"))
            result.success(true)
        } catch (error: Exception) {
            result.error("REVEAL_FAILED", "Could not open the item.", error.message)
        }
    }

    private fun moveItemsToTrash(paths: List<String>?, result: MethodChannel.Result) {
        if (paths.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENT", "Item paths are required.", null)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.error(
                "TRASH_UNSUPPORTED",
                "System Trash requires Android 11 or later.",
                null
            )
            return
        }
        if (pendingTrashResult != null) {
            result.error("TRASH_IN_PROGRESS", "A system Trash request is already open.", null)
            return
        }
        val permissions = if (Build.VERSION.SDK_INT >= 33) {
            arrayOf(
                android.Manifest.permission.READ_MEDIA_IMAGES,
                android.Manifest.permission.READ_MEDIA_VIDEO,
                android.Manifest.permission.READ_MEDIA_AUDIO,
                android.Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED
            )
        } else {
            arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        val hasMediaItems = paths.any(::isMediaPath)
        if (hasMediaItems && !hasAllFilesAccess() && permissions.any {
                ContextCompat.checkSelfPermission(this, it) ==
                    PackageManager.PERMISSION_DENIED
            }) {
            pendingTrashResult = result
            pendingMediaPaths = paths
            ActivityCompat.requestPermissions(this, permissions, REQUEST_MEDIA_PERMISSION)
            return
        }
        requestSystemTrash(paths, result)
    }

    private fun requestSystemTrash(paths: List<String>, result: MethodChannel.Result) {
        try {
            val mediaItems = linkedMapOf<String, Uri>()
            val filePaths = mutableListOf<String>()
            val allFilesAccess = hasAllFilesAccess()
            for (path in paths.distinct()) {
                val item = if (!allFilesAccess && isMediaPath(path)) findMediaStoreItem(path) else null
                if (item?.isMedia == true) {
                    mediaItems[path] = item.uri
                } else {
                    filePaths += path
                }
            }
            if (filePaths.isNotEmpty() && !hasAllFilesAccess()) {
                result.error(
                    "ALL_FILES_ACCESS_REQUIRED",
                    "All files access is required to move documents into Free Space Bin.",
                    null
                )
                return
            }
            if (mediaItems.isEmpty()) {
                val movedFiles = movePathsIntoAppBin(filePaths)
                if (movedFiles.size != filePaths.size) {
                    result.error(
                        "APP_BIN_MOVE_FAILED",
                        "Could not move all selected files into Free Space Bin.",
                        filePaths.filterNot(movedFiles::containsKey)
                    )
                } else {
                    result.success(movedFiles)
                }
                return
            }
            val entries = mediaItems.entries.toList()
            pendingTrashBatches = entries.drop(TRASH_BATCH_SIZE).chunked(TRASH_BATCH_SIZE)
                .map { batch -> batch.associate { it.key to it.value } }
            completedTrashItems.clear()
            pendingFileTrashPaths = filePaths
            pendingTrashResult = result
            pendingRestore = false
            launchTrashBatch(entries.take(TRASH_BATCH_SIZE).associate { it.key to it.value })
        } catch (error: Exception) {
            result.error("TRASH_FAILED", "Could not request system Trash.", error.message)
        }
    }

    private fun launchTrashBatch(pathToUri: Map<String, Uri>) {
        val result = pendingTrashResult ?: return
        try {
            val request = MediaStore.createTrashRequest(
                contentResolver,
                pathToUri.values.toList(),
                true
            )
            pendingTrashItems = pathToUri
            startIntentSenderForResult(
                request.intentSender,
                REQUEST_TRASH,
                null,
                0,
                0,
                0
            )
        } catch (error: Exception) {
            val movedItems = completedTrashItems.toMap()
            clearTrashRequest()
            if (movedItems.isNotEmpty()) {
                result.success(movedItems)
            } else {
                result.error(
                    "TRASH_FAILED",
                    "Could not request system Trash.",
                    error.message
                )
            }
        }
    }

    private fun launchDeleteBatch(pathToUri: Map<String, Uri>) {
        val result = pendingTrashResult ?: return
        try {
            val request = MediaStore.createDeleteRequest(
                contentResolver,
                pathToUri.values.toList()
            )
            pendingTrashItems = pathToUri
            startIntentSenderForResult(
                request.intentSender,
                REQUEST_TRASH,
                null,
                0,
                0,
                0
            )
        } catch (error: Exception) {
            val deletedPaths = completedTrashItems.keys.toList()
            clearTrashRequest()
            if (deletedPaths.isNotEmpty()) {
                result.success(deletedPaths)
            } else {
                result.error(
                    "PERMANENT_DELETE_FAILED",
                    "Could not request permanent deletion from system Trash.",
                    error.message
                )
            }
        }
    }

    private fun clearTrashRequest() {
        pendingTrashResult = null
        pendingTrashItems = emptyMap()
        pendingTrashBatches = emptyList()
        pendingFileTrashPaths = emptyList()
        completedTrashItems.clear()
        pendingAppBinRestoreRollback = emptyList()
        pendingAppBinDeletePaths = emptyList()
        pendingRestore = false
        pendingPermanentDeletePaths = null
    }

    private fun hasAllFilesAccess(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.R ||
            Environment.isExternalStorageManager()

    private fun appBinDirectory(): File =
        File(
            Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            ),
            APP_BIN_DIRECTORY
        )

    private fun isAppBinFile(path: String): File? {
        return try {
            val binPath = appBinDirectory().canonicalPath + File.separator
            val file = File(path).canonicalFile
            file.takeIf { it.path.startsWith(binPath) }
        } catch (_: Exception) {
            null
        }
    }

    private fun movePathsIntoAppBin(paths: List<String>): Map<String, String> {
        if (paths.isEmpty() || !hasAllFilesAccess()) return emptyMap()
        val binDirectory = appBinDirectory()
        if (!binDirectory.exists() && !binDirectory.mkdirs()) return emptyMap()
        val moved = linkedMapOf<String, String>()
        for (path in paths.distinct()) {
            try {
                val source = File(path).canonicalFile
                if (!source.exists() || isAppBinFile(source.path) != null) continue
                val destination = File(
                    binDirectory,
                    "${UUID.randomUUID()}_${source.name}"
                )
                if (source.renameTo(destination)) {
                    moved[path] = destination.absolutePath
                } else {
                    // renameTo failed (e.g., cross-volume or permission denied like Android/data).
                    // We purposefully DO NOT fallback to copy+delete to avoid excessive flash write wear.
                    throw java.io.IOException("renameTo failed for ${source.path}")
                }
            } catch (_: Exception) {
                continue
            }
        }
        return moved
    }

    private fun restoreAppBinFiles(
        items: List<Map<String, String?>>
    ): List<Pair<String, String>> {
        if (!hasAllFilesAccess()) {
            throw SecurityException("All files access is required to restore these files.")
        }
        val restored = mutableListOf<Pair<String, String>>()
        try {
            for (item in items) {
                val originalPath = item["originalPath"]
                    ?: throw IllegalArgumentException("A restore path is missing.")
                val trashPath = item["trashPath"]
                    ?: throw IllegalArgumentException("A Bin path is missing.")
                val source = isAppBinFile(trashPath)
                    ?: throw IllegalArgumentException("The selected file is not in Free Space Bin.")
                val destination = File(originalPath).canonicalFile
                if (destination.exists()) {
                    throw IllegalStateException("A file already exists at $originalPath.")
                }
                destination.parentFile?.let { parent ->
                    if (!parent.exists() && !parent.mkdirs()) {
                        throw IllegalStateException("Could not recreate ${parent.path}.")
                    }
                }
                if (!source.renameTo(destination)) {
                    throw IllegalStateException("Could not restore ${source.name}.")
                }
                restored += source.absolutePath to destination.absolutePath
            }
        } catch (error: Exception) {
            restored.asReversed().forEach { (trashPath, originalPath) ->
                File(originalPath).renameTo(File(trashPath))
            }
            throw error
        }
        return restored
    }

    private fun rollbackAppBinRestores() {
        pendingAppBinRestoreRollback.asReversed().forEach { (trashPath, originalPath) ->
            File(originalPath).renameTo(File(trashPath))
        }
        pendingAppBinRestoreRollback = emptyList()
    }

    private fun deleteAppBinFiles(paths: List<String>): List<String> {
        if (paths.isEmpty() || !hasAllFilesAccess()) return emptyList()
        return paths.filter { path ->
            val file = isAppBinFile(path) ?: return@filter false
            file.deleteRecursively()
        }
    }

    private fun restoreItemsFromTrash(
        items: List<Map<String, String?>>?,
        result: MethodChannel.Result
    ) {
        if (items.isNullOrEmpty()) {
            result.success(true)
            return
        }

        if (pendingTrashResult != null) {
            result.error("TRASH_IN_PROGRESS", "A system Trash request is already open.", null)
            return
        }
        try {
            val appBinItems = items.filter { item ->
                item["trashPath"]?.let(Uri::parse)?.scheme != "content"
            }
            if (appBinItems.isNotEmpty() && !hasAllFilesAccess()) {
                result.error(
                    "ALL_FILES_ACCESS_REQUIRED",
                    "All files access is required to restore documents from Free Space Bin.",
                    null
                )
                return
            }
            val uris = items.mapNotNull { item ->
                item["trashPath"]?.let(Uri::parse)?.takeIf { it.scheme == "content" }
            }
            val restoredFiles = restoreAppBinFiles(appBinItems)
            if (uris.isEmpty()) {
                pendingAppBinRestoreRollback = emptyList()
                result.success(true)
                return
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                restoredFiles.asReversed().forEach { (trashPath, originalPath) ->
                    File(originalPath).renameTo(File(trashPath))
                }
                result.error(
                    "RESTORE_UNSUPPORTED",
                    "System Trash restore requires Android 11 or later.",
                    null
                )
                return
            }
            pendingAppBinRestoreRollback = restoredFiles
            val request = MediaStore.createTrashRequest(contentResolver, uris, false)
            pendingTrashItems = emptyMap()
            pendingRestore = true
            pendingTrashResult = result
            startIntentSenderForResult(
                request.intentSender,
                REQUEST_TRASH,
                null,
                0,
                0,
                0
            )
        } catch (error: Exception) {
            rollbackAppBinRestores()
            result.error("RESTORE_FAILED", "Could not request restore from Trash.", error.message)
        }
    }

    private fun permanentlyDeleteItemsFromTrash(
        paths: List<String>?,
        result: MethodChannel.Result
    ) {
        if (paths.isNullOrEmpty()) {
            result.success(emptyList<String>())
            return
        }
        val appBinPaths = paths.filter { Uri.parse(it).scheme != "content" }
        val mediaPaths = paths.filter { Uri.parse(it).scheme == "content" }
        if (pendingTrashResult != null) {
            result.error("TRASH_IN_PROGRESS", "A system Trash request is already open.", null)
            return
        }
        if (appBinPaths.isNotEmpty() && !hasAllFilesAccess()) {
            result.error(
                "ALL_FILES_ACCESS_REQUIRED",
                "All files access is required to permanently delete documents from Free Space Bin.",
                null
            )
            return
        }
        if (mediaPaths.isEmpty()) {
            result.success(deleteAppBinFiles(appBinPaths))
            return
        }
        try {
            val pathToUri = mediaPaths.associateWith { path ->
                Uri.parse(path).takeIf { it.scheme == "content" }
                    ?: throw IllegalArgumentException(
                        "Invalid MediaStore Trash location: $path"
                    )
            }
            val entries = pathToUri.entries.toList()
            pendingTrashBatches = entries.drop(TRASH_BATCH_SIZE).chunked(TRASH_BATCH_SIZE)
                .map { batch -> batch.associate { it.key to it.value } }
            completedTrashItems.clear()
            pendingRestore = false
            pendingPermanentDeletePaths = mediaPaths
            pendingAppBinDeletePaths = appBinPaths
            pendingTrashResult = result
            launchDeleteBatch(entries.take(TRASH_BATCH_SIZE).associate { it.key to it.value })
        } catch (error: Exception) {
            clearTrashRequest()
            result.error(
                "PERMANENT_DELETE_FAILED",
                "Could not request permanent deletion from system Trash.",
                error.message
            )
        }
    }

    private fun listSystemTrashItems(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(emptyList<Map<String, Any>>())
            return
        }
        try {
            val collection = MediaStore.Files.getContentUri("external")
            val projection = arrayOf(
                MediaStore.Files.FileColumns._ID,
                MediaStore.Files.FileColumns.DISPLAY_NAME,
                MediaStore.Files.FileColumns.SIZE
            )
            val items = mutableListOf<Map<String, Any>>()
            contentResolver.query(
                collection,
                projection,
                "${MediaStore.Files.FileColumns.IS_TRASHED} = ?",
                arrayOf("1"),
                "${MediaStore.Files.FileColumns.DISPLAY_NAME} COLLATE NOCASE ASC"
            )?.use { cursor ->
                val idColumn =
                    cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID)
                val nameColumn =
                    cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DISPLAY_NAME)
                val sizeColumn =
                    cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.SIZE)
                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    items += mapOf(
                        "name" to cursor.getString(nameColumn),
                        "trashPath" to Uri.withAppendedPath(collection, id.toString()).toString(),
                        "sizeBytes" to cursor.getLong(sizeColumn).coerceAtLeast(0L)
                    )
                }
            }
            result.success(items)
        } catch (error: Exception) {
            result.error(
                "SYSTEM_TRASH_READ_FAILED",
                "Could not read Android system Trash.",
                error.message
            )
        }
    }

    private fun findMediaStoreItem(path: String): MediaStoreItem? {
        val collection = MediaStore.Files.getContentUri("external")
        val projection = arrayOf(
            MediaStore.Files.FileColumns._ID,
            MediaStore.Files.FileColumns.MEDIA_TYPE
        )
        contentResolver.query(
            collection,
            projection,
            "${MediaStore.Files.FileColumns.DATA} = ?",
            arrayOf(path),
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val id = cursor.getLong(
                    cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID)
                )
                val mediaType = cursor.getInt(
                    cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.MEDIA_TYPE)
                )
                return MediaStoreItem(
                    uri = Uri.withAppendedPath(collection, id.toString()),
                    isMedia = mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE ||
                        mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO ||
                        mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                )
            }
        }
        return null
    }

    private fun isMediaPath(path: String): Boolean {
        val mimeType = MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(File(path).extension.lowercase())
            ?: return false
        return mimeType.startsWith("image/") ||
            mimeType.startsWith("audio/") ||
            mimeType.startsWith("video/")
    }
}
