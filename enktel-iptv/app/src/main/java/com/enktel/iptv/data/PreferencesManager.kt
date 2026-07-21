package com.enktel.iptv.data

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.enktel.iptv.data.model.AppCredentials
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PreferencesManager @Inject constructor(
    private val dataStore: DataStore<Preferences>
) {
    companion object {
        private val SERVER_URL = stringPreferencesKey("server_url")
        private val USERNAME = stringPreferencesKey("username")
        private val PASSWORD = stringPreferencesKey("password")
    }

    val credentials: Flow<AppCredentials> = dataStore.data.map { prefs ->
        AppCredentials(
            serverUrl = prefs[SERVER_URL] ?: "",
            username = prefs[USERNAME] ?: "",
            password = prefs[PASSWORD] ?: ""
        )
    }

    suspend fun saveCredentials(credentials: AppCredentials) {
        dataStore.edit { prefs ->
            prefs[SERVER_URL] = credentials.serverUrl
            prefs[USERNAME] = credentials.username
            prefs[PASSWORD] = credentials.password
        }
    }

    suspend fun clearCredentials() {
        dataStore.edit { it.clear() }
    }
}
