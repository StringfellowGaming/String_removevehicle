Config = {}

Config.RequiredPermission = 'admin'

Config.AllowedGroups = {
    'admin',
    'moderator',
    'god'
}

Config.VehicleTable = 'player_vehicles'

Config.EnableLogging = true

Config.LogFile = 'vehicle_removals.log'

Config.DiscordWebhook = {
    enabled = false,
    url = '',
    username = 'Vehicle Removal System',
    avatar = 'https://cdn.discordapp.com/attachments/example.png'
}

Config.Notifications = {
    success_color = 'success',
    error_color = 'error',
    info_color = 'primary'
}

Config.CommandCooldown = 5

Config.MaxVehiclesList = 20