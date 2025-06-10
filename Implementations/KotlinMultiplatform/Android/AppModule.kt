package com.admi126n.magisterka

import com.admi126n.magisterka.cache.AndroidDatabaseDriverFactory
import com.admi126n.magisterka.cache.Database
import org.koin.android.ext.koin.androidContext
import org.koin.dsl.module

val databaseModule = module {
    single { AndroidDatabaseDriverFactory(androidContext()) }
    single { Database(get()) }
}