package com.example.kotlinapp

import android.app.Application
import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.kotlinapp.ui.theme.KotlinAppTheme

class PeopleApp: Application() {
    override fun onCreate() {
        super.onCreate()
        Graph.provide(this)
    }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            KotlinAppTheme {
                MainView(this)
            }
        }
    }
}

@Composable
fun MainView(context: Context) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(modifier = Modifier.size(100.dp))

        DatabaseTestsView(numberOfTests = 110, numberOfInstances = 1000)

        JSONTestsView(numberOfTests = 10, context)

        BenchmarksView(
            numberOfTests = 110,
            fannkuchRedux = 8,
            fasta = 100_000,
            nBody = 100_000,
            reverseComplement = 100_000
        )
    }
}
