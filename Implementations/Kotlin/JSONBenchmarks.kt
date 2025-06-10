package com.example.kotlinapp

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import java.io.IOException
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Composable
fun JSONTestsView(numberOfTests: Int, context: Context) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        val files = listOf<String>("API_1", "API_100", "API_1000", "API_10000", "API_33462")

        Button(onClick = {
            for (file in files) {
                val tester = JSONTester(context)
                val dataString = tester.getDataFromAssets(file)!!
                val objects = tester.encode(dataString)!!

                for (i in 0..<numberOfTests) {
                    val start = System.nanoTime()
                    tester.encode(dataString)
                    val end = System.nanoTime()

                    Log.d("JSON TIME", "(${i + 1}/$numberOfTests) ENCODE $file; ${end - start} [ns]")
                }

                for (i in 0..<numberOfTests) {
                    val start = System.nanoTime()
                    tester.decode(objects)
                    val end = System.nanoTime()

                    Log.d("JSON TIME", "(${i + 1}/$numberOfTests) DECODE $file; ${end - start} [ns]")
                }
            }
        },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Green)
        ) {
            Text("Run JSON tests")
        }
    }
}

@SuppressLint("UnsafeOptInUsageError")
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

class JSONTester(private val context: Context) {

    fun getDataFromAssets(file: String): String? {
        return try {
            val r = context.assets.open("$file.json").bufferedReader().use { it.readText() }
            Log.d("LOADED STRING", r)
            return r
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

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