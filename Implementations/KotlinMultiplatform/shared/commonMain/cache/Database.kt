package com.admi126n.magisterka.cache

import com.admi126n.magisterka.person.Person

class Database(databaseDriverFactory: DatabaseDriverFactory) {
    private val database = AppDatabase(databaseDriverFactory.createDriver())
    private val dbQuery = database.appDatabaseQueries

    fun selectPerson(person: Person): List<People> {
        return dbQuery.selectPerson(person.name).executeAsList()
    }

    fun selectPeople(): List<People> {
        return dbQuery.selectPeople().executeAsList()
    }

    fun insertPerson(person: Person) {
        dbQuery.insertPerson(person.name)
    }

    fun insertPeople(people: List<Person>) {
        for (person in people) {
            dbQuery.insertPerson(person.name)
        }
    }

    fun updatePerson(person: Person) {
        dbQuery.updatePerson(person.name)
    }

    fun updatePeople(people: List<Person>) {
        for (person in people) {
            dbQuery.updatePerson(person.name)
        }
    }

    fun deletePerson(person: Person) {
        dbQuery.removePerson(person.name)
    }

    fun deletePeople() {
        dbQuery.removeAllPeople()
    }
}