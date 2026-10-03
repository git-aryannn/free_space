package com.example.free_space

import android.os.FileObserver
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ObserverManager(private val channel: MethodChannel) {
    private val observers = mutableListOf<FileObserver>()

    fun startObserving(paths: List<String>) {
        stopObserving()
        for (path in paths) {
            val observer = object : FileObserver(path, FileObserver.CREATE or FileObserver.MOVED_TO) {
                override fun onEvent(event: Int, file: String?) {
                    if (file == null) return
                    val fullPath = File(path, file).absolutePath
                    val f = File(fullPath)
                    if (!f.exists()) return
                    
                    val size = f.length()
                    val data = mapOf(
                        "path" to fullPath,
                        "name" to file,
                        "sizeBytes" to size
                    )
                    
                    // Send to flutter on main thread
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        channel.invokeMethod("onNewFileDetected", data)
                    }
                }
            }
            observer.startWatching()
            observers.add(observer)
        }
    }

    fun stopObserving() {
        for (obs in observers) {
            obs.stopWatching()
        }
        observers.clear()
    }
}
