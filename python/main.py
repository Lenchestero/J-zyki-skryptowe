import ollama
import discord
from discord import app_commands

LLM_MODEL = "gemma3:12b"
DISCORD_TOKEN = ""

intents = discord.Intents.default()
client = discord.Client(intents=intents)
command_tree = app_commands.CommandTree(client)

teams_data = [{"team": "Killphoria", "players": ["Adolf", "Agnieszka", "Albert", "Hipacy", "Izaur"]},
{"team": "Pixel Armada", "players": ["Awit", "Awita", "Drogomysł", "Izaura", "Marcjan"]},
{"team": "Arcane Rift", "players": ["Franciszek", "Gundolf", "Herweusz", "Nikander", "Nikandra"]}]

tournament_name = ""
current_brackets = ""

def ask_llm(prompt):
    response = ollama.chat(model=LLM_MODEL, messages=[{"role": "user", "content": prompt}])
    response = response["message"]["content"]
    return response

@command_tree.command(name="introduction", description="Introduction to the tournament")
async def introduction(interaction: discord.Interaction, game: str):
    await interaction.response.defer(thinking=True)
    global tournament_name
    tournament_name = ask_llm(("Create some fancy name for e-sport tournament. Output only this name"))
    prompt = (
        f"Give introduction to the {game} e-sport tournament named {tournament_name}. Come up with a reward. Invite to participate. Don't make it long."
    )
    result = ask_llm(prompt)
    await interaction.followup.send(result[:2000])

@command_tree.command(name="score_system_in_team", description="Generate ranking of players in team")
async def scoring_players(interaction: discord.Interaction, team: str):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Here are the data of current teams:{teams_data}. Generate ranking of players on the team {team}. Come up with their k/d/a statistics from past tournaments and base your ranking on it. Output only the ranking with statistics, don't add other explanation."
    )
    result = ask_llm(prompt)
    await interaction.followup.send(result[:2000])

@command_tree.command(name="score_system", description="Generate ranking of teams")
async def scoring_teams(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    prompt = (
        f"Here are the data of current teams: {teams_data}. Come up with how many wins they had in past tournaments and their ranking based on it. Output only the ranking with wins, don't add other explanation."
    )
    result = ask_llm(prompt)
    await interaction.followup.send(result[:2000])

@command_tree.command(name="tournament_brackets", description="List current games")
async def tournament_brackets(interaction: discord.Interaction):
    await interaction.response.defer(thinking=True)
    global current_brackets
    prompt = (
        f"Here are the data of current teams: {teams_data}. Print out the current stage of tournament- possible stages- quarterfinals, semifinals, finals. Then create brackets for the teams (which teams vs which team). Don't add any other explanation."
    )
    current_brackets = ask_llm(prompt)
    await interaction.followup.send(current_brackets)

@command_tree.command(name="add_team", description="Add team to game")
async def add_team(interaction: discord.Interaction, team_name:str):
    await interaction.response.defer(thinking=True)
    teams_data.append({"team": team_name, "players": []})
    prompt = (
        f"Successfully added {team_name} to {tournament_name}"
    )
    await interaction.followup.send(prompt)

@command_tree.command(name="add_player", description="Add player to team")
async def add_player(interaction: discord.Interaction, team_name:str, player:str):
    await interaction.response.defer(thinking=True)
    for team in teams_data:
        if team["team"] == team_name:
            team["players"].append(player)
            prompt = (
                f"Successfully added {player} to {team_name}"
            )
        else:
            prompt = ("Team not found.")

    await interaction.followup.send(prompt)

@client.event
async def on_ready():
    await command_tree.sync()
    print("Bot connected successfully")

await client.start(DISCORD_TOKEN)