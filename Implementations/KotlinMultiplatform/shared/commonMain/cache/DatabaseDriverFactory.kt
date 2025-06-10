package com.admi126n.magisterka.cache

import app.cash.sqldelight.db.SqlDriver

interface DatabaseDriverFactory {
    fun createDriver(): SqlDriver
}