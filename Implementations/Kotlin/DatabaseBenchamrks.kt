package com.example.kotlinapp

import android.content.Context
import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Delete
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch


@Composable
fun DatabaseTestsView(numberOfTests: Int, numberOfInstances: Int) {
    val vm = PeopleViewModel()

    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Button(onClick = {
            val people = (0..<numberOfInstances).map {
                Person(id = it, name = "Hello $it")
            }

            vm.atomicTests(people, numberOfInstances, numberOfTests)
        }) {
            Text("Run database atomic tests")
        }

        Button(onClick = {
            val people = (0..<numberOfInstances).map {
                Person(id = it, name = "Hello $it")
            }

            vm.fullTests(people, numberOfInstances, numberOfTests)
        }) {
            Text("Run full database tests")
        }
    }
}

class PeopleViewModel: ViewModel() {
    private val repo = Graph.peopleRepository

    fun atomicTests(people: List<Person>, numberOfInstances: Int, numberOfTests: Int) {
        viewModelScope.launch {
            for (i in (0..<numberOfTests)) {
                val start = System.nanoTime()
                repo.insertPeople(people)
                val end = System.nanoTime()

                repo.deleteAllPeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) INSERT $numberOfInstances instances; ${end - start} [ns]"
                )
            }

            for (i in (0..<numberOfTests)) {
                repo.insertPeople(people)
                val start = System.nanoTime()
                repo.selectPeople()
                val end = System.nanoTime()

                repo.deleteAllPeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) SELECT $numberOfInstances instances; ${end - start} [ns]")
            }

            for (i in (0..<numberOfTests)) {
                repo.insertPeople(people)
                val start = System.nanoTime()
                repo.updatePeople(people)
                val end = System.nanoTime()

                repo.deleteAllPeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) UPDATE $numberOfInstances instances; ${end - start} [ns]")
            }

            for (i in (0..<numberOfTests)) {
                repo.insertPeople(people)
                val start = System.nanoTime()
                repo.deleteAllPeople()
                val end = System.nanoTime()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) DELETE $numberOfInstances instances; ${end - start} [ns]")
            }
        }
    }

    fun fullTests(people: List<Person>, numberOfInstances: Int, numberOfTests: Int) {
        viewModelScope.launch {
            for (i in (0..<numberOfTests)) {
                val start = System.nanoTime()
                repo.insertPeople(people)
                repo.selectPeople()
                repo.updatePeople(people)
                repo.deleteAllPeople()
                val end = System.nanoTime()

                Log.d(
                    "FULL DATABASE TIME",
                    "(${i + 1}/$numberOfTests) DATABASE $numberOfInstances instances; ${end - start} [ns]")
            }
        }
    }
}

@Entity(tableName = "people")
data class Person(
    @PrimaryKey(autoGenerate = true)
    val id: Int,
    @ColumnInfo(name = "name")
    val name: String
)

@Dao
abstract class PersonDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    abstract suspend fun insertPerson(personEntity: Person)

    @Query("SELECT * FROM 'people' WHERE name=:argName")
    abstract fun selectPerson(argName: String): Flow<List<Person>>

    @Query("SELECT * FROM 'people'")
    abstract fun selectPeople(): Flow<List<Person>>

    @Query("UPDATE 'people' SET name='hello' WHERE name = :argName")
    abstract suspend fun updatePerson(argName: String)

    @Query("DELETE FROM 'people'")
    abstract suspend fun deletePeople()

    @Delete
    abstract suspend fun deletePerson(personEntity: Person)
}

@Database(
    entities = [Person::class],
    version = 1,
    exportSchema = false
)
abstract class PeopleDatabase: RoomDatabase() {
    abstract fun personDao(): PersonDao
}

class PeopleRepository(private val personDao: PersonDao) {
    suspend fun insertPeople(people: List<Person>) {
        for (person in people) {
            personDao.insertPerson(person)
        }
    }

    fun selectPeople(): Flow<List<Person>> {
        return personDao.selectPeople()
    }

    suspend fun updatePeople(people: List<Person>) {
        for (person in people) {
            personDao.updatePerson(person.name)
        }
    }

    suspend fun deleteAllPeople() {
        personDao.deletePeople()
    }
}

object Graph {
    lateinit var database: PeopleDatabase

    val peopleRepository by lazy {
        PeopleRepository(database.personDao())
    }

    fun provide(context: Context) {
        database = Room.databaseBuilder(context, PeopleDatabase::class.java, "people.db").build()
    }
}