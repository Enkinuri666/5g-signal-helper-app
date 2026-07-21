package com.enktel.iptv.ui.screens.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.enktel.iptv.data.repository.ConnectionState
import com.enktel.iptv.data.repository.ContentRepository
import com.enktel.iptv.ui.components.GlassCard
import com.enktel.iptv.ui.theme.EnktelColors

@Composable
fun SettingsScreen(
    repository: ContentRepository,
    onLogout: () -> Unit
) {
    val connectionState by repository.connectionState.collectAsState()

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(EnktelColors.Background)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(vertical = 16.dp)
    ) {
        item {
            Text(
                text = "Settings",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = EnktelColors.TextPrimary
            )
            Spacer(modifier = Modifier.height(8.dp))
        }

        // Account info
        item {
            GlassCard(modifier = Modifier.fillMaxWidth(), cornerRadius = 16.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Account", style = MaterialTheme.typography.titleMedium, color = EnktelColors.TextPrimary, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(12.dp))

                    when (val state = connectionState) {
                        is ConnectionState.Connected -> {
                            val user = state.serverInfo.userInfo
                            SettingsRow(icon = Icons.Filled.Person, label = "Username", value = user?.username ?: "-")
                            SettingsRow(icon = Icons.Filled.CheckCircle, label = "Status", value = user?.status ?: "-")
                            SettingsRow(icon = Icons.Filled.Schedule, label = "Expires", value = user?.expDate ?: "N/A")
                            SettingsRow(icon = Icons.Filled.Devices, label = "Connections", value = "${user?.activeCons ?: 0}/${user?.maxConnections ?: 1}")
                        }
                        else -> {
                            Text("Not connected", color = EnktelColors.TextSecondary)
                        }
                    }
                }
            }
        }

        // Server info
        item {
            GlassCard(modifier = Modifier.fillMaxWidth(), cornerRadius = 16.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Server", style = MaterialTheme.typography.titleMedium, color = EnktelColors.TextPrimary, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(12.dp))

                    when (val state = connectionState) {
                        is ConnectionState.Connected -> {
                            val server = state.serverInfo.serverInfo
                            SettingsRow(icon = Icons.Filled.Dns, label = "Server", value = server?.url ?: "-")
                            SettingsRow(icon = Icons.Filled.Language, label = "Timezone", value = server?.timezone ?: "-")
                        }
                        else -> {
                            Text("Not connected", color = EnktelColors.TextSecondary)
                        }
                    }
                }
            }
        }

        // App info
        item {
            GlassCard(modifier = Modifier.fillMaxWidth(), cornerRadius = 16.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("App", style = MaterialTheme.typography.titleMedium, color = EnktelColors.TextPrimary, fontWeight = FontWeight.Bold)
                    Spacer(modifier = Modifier.height(12.dp))
                    SettingsRow(icon = Icons.Filled.Info, label = "Version", value = "2.0.0")
                    SettingsRow(icon = Icons.Filled.Build, label = "Build", value = "Enktel IPTV")
                }
            }
        }

        // Logout
        item {
            Spacer(modifier = Modifier.height(8.dp))
            Button(
                onClick = {
                    repository.disconnect()
                    onLogout()
                },
                modifier = Modifier.fillMaxWidth().height(52.dp),
                colors = ButtonDefaults.buttonColors(containerColor = EnktelColors.LiveRed),
                shape = RoundedCornerShape(12.dp)
            ) {
                Icon(Icons.Filled.Logout, null, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Disconnect", style = MaterialTheme.typography.titleSmall)
            }
            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}

@Composable
private fun SettingsRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    value: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(icon, null, tint = EnktelColors.TextTertiary, modifier = Modifier.size(18.dp))
            Text(label, style = MaterialTheme.typography.bodyMedium, color = EnktelColors.TextSecondary)
        }
        Text(value, style = MaterialTheme.typography.bodyMedium, color = EnktelColors.TextPrimary, fontWeight = FontWeight.Medium)
    }
}
