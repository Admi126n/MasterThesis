package com.admi126n.magisterka

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class APIResponse(
    val brake: Int,
    val date: String,
    val driver_number: Int,
    val drs: Int,
    val meeting_key: Int,
    val n_gear: Int,
    val rpm: Int,
    val session_key: Int,
    val speed: Int,
    val throttle: Int
)

class JSONTester() {
    fun encode(string: String): List<APIResponse>? {
        return try {
            Json.decodeFromString<List<APIResponse>>(string)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun decode(objects: List<APIResponse>): String? {
        return try {
            Json.encodeToString(objects)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}