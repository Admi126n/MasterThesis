package com.admi126n.magisterka

import android.content.Context
import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.ButtonDefaults
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.admi126n.magisterka.cache.AndroidDatabaseDriverFactory
import com.admi126n.magisterka.cache.Database
import com.admi126n.magisterka.person.Person
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun App() {
    MaterialTheme {
        MainView(LocalContext.current)
    }
}

@Composable
fun MainView(context: Context) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(modifier = Modifier.size(100.dp))

        DatabaseTestsView(numberOfTests = 110, numberOfInstances = 1_000, context)

        JSONTestsView(numberOfTests = 110, context)

        BenchmarksView(
            numberOfTests = 110,
            fannkuchRedux = 8,
            fasta = 100_000,
            nBody = 100_000,
            reverseComplement = 100_000
        )
    }
}

class TimeCounter {
    companion object {
        fun measure(arg: () -> Unit): Long {
            val start = System.nanoTime()
            arg()
            val end = System.nanoTime()

            return end - start
        }
    }
}

@Composable
fun DatabaseTestsView(numberOfTests: Int, numberOfInstances: Int, context: Context) {
    val driver = AndroidDatabaseDriverFactory(context)
    val database = Database(driver)

    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
        Spacer(modifier = Modifier.size(100.dp))

        Button(onClick = {
            val people = (0..<numberOfInstances).map {
                Person(name = "Hello $it")
            }

            // insert
            for (i in (0..<numberOfTests)) {
                val time = TimeCounter.measure {
                    database.insertPeople(people)
                }

                database.deletePeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) INSERT $numberOfInstances instances; $time [ns]")
            }

            // select
            for (i in (0..<numberOfTests)) {
                database.insertPeople(people)

                val time = TimeCounter.measure {
                    database.selectPeople()
                }

                database.deletePeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) SELECT $numberOfInstances instances; $time [ns]")
            }

            // update
            for (i in (0..<numberOfTests)) {
                database.insertPeople(people)

                val time = TimeCounter.measure {
                    database.updatePeople(people)
                }

                database.deletePeople()

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) UPDATE $numberOfInstances instances; $time [ns]")
            }

            // delete
            for (i in (0..<numberOfTests)) {
                database.insertPeople(people)

                val time = TimeCounter.measure {
                    database.deletePeople()
                }

                Log.d(
                    "ATOMIC DATABASE TIME",
                    "(${i + 1}/$numberOfTests) DELETE $numberOfInstances instances; $time [ns]")
            }
        }) {
            Text("Run database atomic tests")
        }

        Button(onClick = {
            val people = (0..<numberOfInstances).map {
                Person(name = "Hello $it")
            }

            for (i in (0..<numberOfTests)) {
                val time = TimeCounter.measure {
                    database.insertPeople(people)
                    database.selectPeople()
                    database.updatePeople(people)
                    database.deletePeople()
                }

                Log.d(
                    "FULL DATABASE TIME",
                    "(${i + 1}/$numberOfTests) DATABASE $numberOfInstances instances; $time [ns]")
            }
        }) {
            Text("Run full database tests")
        }
    }
}

@Composable
fun JSONTestsView(numberOfTests: Int, context: Context) {
    val files = listOf<String>("API_1", "API_100", "API_1000", "API_10000", "API_33462")

    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Button(
            onClick = {
                for (file in files) {
                    val tester = JSONTester()
                    val data =
                        context.assets.open("$file.json").bufferedReader().use { it.readText() }
                    val objects = tester.encode(data)!!

                    for (i in 0..<numberOfTests) {
                        val time = TimeCounter.measure {
                            tester.encode(data)
                        }

                        Log.d("JSON TIME", "(${i + 1}/$numberOfTests) ENCODE $file; $time [ns]")
                    }

                    for (i in 0..<numberOfTests) {
                        val time = TimeCounter.measure {
                            tester.decode(objects)
                        }

                        Log.d("JSON TIME", "(${i + 1}/$numberOfTests) DECODE $file; $time [ns]")
                    }
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Green)
        ) {
            Text("Run JSON tests")
        }
    }
}

@Composable
fun BenchmarksView(numberOfTests: Int, fannkuchRedux: Int, fasta: Int, nBody: Int, reverseComplement: Int) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Button(
            onClick = {
                val fr = FannkuchRedux()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    fr.runBenchmark(fannkuchRedux)
                    val end = System.nanoTime()

                    Log.d(
                        "FANNKUCH TIME",
                        "(${i + 1}/$numberOfTests) FannkuchRedux; ${end - start} [ns]"
                    )
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run FannkuchRedux")
        }

        Button(
            onClick = {
                val f = Fasta()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    f.runBenchmark(fasta)
                    val end = System.nanoTime()

                    Log.d("FASTA TIME", "(${i + 1}/$numberOfTests) Fasta; ${end - start} [ns]")
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run Fasta")
        }

        Button(
            onClick = {
                val n = NBody()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    n.runBenchmark(nBody)
                    val end = System.nanoTime()

                    Log.d("NBODY TIME", "(${i + 1}/$numberOfTests) NBody; ${end - start} [ns]")
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run NBody")
        }

        Button(
            onClick = {
                val r = ReverseComplement()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    r.runBenchmark(reverseComplement)
                    val end = System.nanoTime()

                    Log.d(
                        "REVERSECOMPLEMENT TIME",
                        "(${i + 1}/$numberOfTests) ReverseComplement; ${end - start} [ns]"
                    )
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run ReverseComplement")
        }
    }
}