package com.hn.minddiji

import android.content.Context
import android.content.SharedPreferences

object BlockPreferenceManager {

    private const val PREF_NAME = "minddiji_block"
    private const val KEY_BLOCKED_DATA = "blocked_packages_individual" 

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

    // 1. Aktifkan blokir untuk SATU package secara mandiri selama durationMs
    fun startBlock(context: Context, packageName: String, durationMs: Long) {
        val p = prefs(context)
        val existingSet = p.getStringSet(KEY_BLOCKED_DATA, emptySet())?.toMutableSet() ?: mutableSetOf()

        // Hapus data lama package ini jika sebelumnya sudah ada
        existingSet.removeAll { it.startsWith("$packageName|") }

        // Hitung waktu kedaluwarsa spesifik untuk aplikasi ini
        val endTime = System.currentTimeMillis() + durationMs
        existingSet.add("$packageName|$endTime")

        p.edit().putStringSet(KEY_BLOCKED_DATA, existingSet).apply()
    }

    // Overload fungsi jika ada kode lamamu yang mengirim data berbentuk Set<String>
    fun startBlock(context: Context, packages: Set<String>, durationMs: Long) {
        for (pkg in packages) {
            startBlock(context, pkg, durationMs)
        }
    }

    // 2. Cek apakah package ini sedang diblokir
    fun isBlocked(context: Context, packageName: String): Boolean {
        val map = getBlockedPackagesMap(context)
        return map.containsKey(packageName)
    }

    // 3. Ambil daftar semua aplikasi beserta SISA WAKTUNYA masing-masing
    fun getBlockedPackagesMap(context: Context): Map<String, Long> {
        val p = prefs(context)
        val existingSet = p.getStringSet(KEY_BLOCKED_DATA, emptySet()) ?: emptySet()
        val now = System.currentTimeMillis()

        val resultMap = mutableMapOf<String, Long>()
        val updatedSet = mutableSetOf<String>()
        var isChanged = false

        for (item in existingSet) {
            val parts = item.split("|")
            if (parts.size == 2) {
                val pkg = parts[0]
                val endTime = parts[1].toLongOrNull() ?: 0L
                val remaining = endTime - now

                if (remaining > 0) {
                    resultMap[pkg] = remaining
                    updatedSet.add(item)
                } else {
                    isChanged = true
                }
            }
        }

        if (isChanged) {
            p.edit().putStringSet(KEY_BLOCKED_DATA, updatedSet).apply()
        }

        return resultMap
    }

    // 4. Hapus blokir untuk SATU aplikasi secara mandiri
    fun clearBlockForPackage(context: Context, packageName: String) {
        val p = prefs(context)
        val existingSet = p.getStringSet(KEY_BLOCKED_DATA, emptySet())?.toMutableSet() ?: mutableSetOf()

        val isRemoved = existingSet.removeAll { it.startsWith("$packageName|") }
        if (isRemoved) {
            p.edit().putStringSet(KEY_BLOCKED_DATA, existingSet).apply()
        }
    }

    // =================================================================
    //  FUNGSI PENYELAMAT SINKRONISASI (Mengatasi Eror Kompilasi Kamu)
    // =================================================================

    // Menghilangkan eror: Unresolved reference 'clearBlock' di MainActivity & Service
    fun clearBlock(context: Context) {
        prefs(context).edit().remove(KEY_BLOCKED_DATA).apply()
    }

    // Menghilangkan eror: Unresolved reference 'blockedPackages'
    fun blockedPackages(context: Context): Set<String> {
        return getBlockedPackagesMap(context).keys
    }

    // Menghilangkan eror: Unresolved reference 'remainingMs' (Mengambil sisa waktu tertinggi)
    fun remainingMs(context: Context): Long {
        val map = getBlockedPackagesMap(context)
        return map.values.maxOrNull() ?: 0L
    }

    // Fungsi tambahan cerdas untuk mengambil sisa waktu spesifik per aplikasi saat hitung mundur overlay
    fun remainingMsForPackage(context: Context, packageName: String): Long {
        val map = getBlockedPackagesMap(context)
        return map[packageName] ?: 0L
    }
}