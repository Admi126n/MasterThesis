package com.admi126n.magisterka.cache

import android.content.Context
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver

public class AndroidDatabaseDriverFactory(private val context: Context) : DatabaseDriverFactory {
    override fun createDriver(): SqlDriver {
        return AndroidSqliteDriver(AppDatabase.Schema, context, "people.db")
    }
}
