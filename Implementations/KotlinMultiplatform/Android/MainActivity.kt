package com.admi126n.magisterka

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.GlobalContext.startKoin

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            App()
        }

        startKoin {
            androidContext(this@MainActivity)
            modules(databaseModule)
        }
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
    App()
}