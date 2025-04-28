# TerritoryManager.gd
# TerritoryManager is responsible for managing the territories in the game.
# It handles the generation of territories meshes.
class_name TerritoryManager
extends Node

class Team:
    var id: int
    var name: String
    var color: Color

class TerritoryTile:
    var team_id: int
    var position: Vector2i
    var weight: float = 1.0
    var territory: Territory = null

class Territory:
    var team_id: int
    var mesh: Mesh

class PackedTerritory:
    var elements: Array[Territory]

var tiles: SpatialGrid = SpatialGrid.new()
var teams: Dictionary[int, Team] = {}

const MARCHING_SQUARES_TABLE: Array[PackedVector2Array] = [
    [Vector2(0.0, 0.5), Vector2(0.5, 1.0)],
    [Vector2(0.5, 1.0), Vector2(1.0, 0.5)],
    [Vector2(0.0, 0.5), Vector2(1.0, 0.5)],
    [Vector2(1.0, 0.5), Vector2(0.5, 0.0)],
    [Vector2(0.0, 0.5), Vector2(0.5, 0.0), Vector2(0.5, 1.0), Vector2(1.0, 0.5)],
    [Vector2(0.5, 1.0), Vector2(0.5, 0.0)],
    [Vector2(0.0, 0.5), Vector2(0.5, 0.0)],
    [Vector2(0.5, 0.0), Vector2(0.0, 0.5)],
    [Vector2(0.5, 0.0), Vector2(0.5, 1.0)],
    [Vector2(0.5, 0.0), Vector2(1.0, 0.5), Vector2(0.0, 0.5), Vector2(0.5, 1.0)],
    [Vector2(1.0, 0.5), Vector2(0.5, 1.0)],
    [Vector2(1.0, 0.5), Vector2(0.0, 0.5)],
    [Vector2(1.0, 0.5), Vector2(0.5, 0.0)],
    [Vector2(0.5, 1.0), Vector2(0.0, 0.5)],
]

func _ready() -> void:
    update_team(0, "Team 1", Color(1, 0, 0)) # Red
    update_team(1, "Team 2", Color(0, 1, 0)) # Green
    update_team(2, "Team 3", Color(0, 0, 1)) # Blue
    update_team(3, "Team 4", Color(1, 1, 0)) # Yellow

    claim_territory(0, Vector2(5, 5), 1.0, 1.0)
    claim_territory(0, Vector2(5, 6), 1.0, 1.0)
    claim_territory(0, Vector2(5, 7), 1.0, 1.0)
    claim_territory(1, Vector2(6, 6), 1.0, 1.0)
    claim_territory(1, Vector2(6, 7), 1.0, 1.0)
    claim_territory(1, Vector2(6, 8), 1.0, 1.0)
    claim_territory(2, Vector2(7, 6), 1.0, 1.0)
    claim_territory(1, Vector2(6, 5), 1.0, 1.0)
    claim_territory(2, Vector2(7, 5), 1.0, 1.0)
    claim_territory(3, Vector2(8, 5), 1.0, 1.0)


func update_team(team_id: int, team_name: String, color: Color) -> void:
    if team_id < 0:
        push_error("Invalid team ID.")
        return # Invalid team ID
    var team: Team = Team.new()
    team.id = team_id
    team.name = team_name
    team.color = color
    teams[team_id] = team

func get_team(team_id: int) -> Team:
    return teams.get(team_id, null)
func delete_team(team_id: int) -> void:
    teams.erase(team_id)

func claim_territory(team_id: int, position: Vector2, radius: float, weight: float = 1) -> void:
    var rounded_position: Vector2i = Vector2i(int(position.x), int(position.y))
    if not tiles.has(rounded_position):
        return # No territory to claim, this is out of bounds.
    for tile: TerritoryTile in tiles.values():
        if tile.position.distance_to(rounded_position) <= radius:
            if tile.weight > weight:
                return # This tile is already claimed by a stronger team.
            tile.team_id = team_id
            tile.weight = weight
            tile.territory = _get_adjoining_territory(team_id, tile.position)
            if tile.territory == null:
                tile.territory = Territory.new()
            tile.territory.team_id = team_id

    # Update the territory mesh for the team
    generate()

func _get_adjoining_territory(team_id: int, position: Vector2) -> Territory:
    for tile: TerritoryTile in tiles.values():
        if tile.team_id == team_id and tile.position.distance_to(position) <= 1:
            return tile.territory
    return null

func release_territory(position: Vector2, radius: float) -> void:
    var rounded_position: Vector2i = Vector2i(int(position.x), int(position.y))
    if not tiles.has(rounded_position):
        return # No territory to release, this is out of bounds.
    for tile: TerritoryTile in tiles.values():
        if tile.position.distance_to(rounded_position) <= radius:
            tile.team_id = -1 # Release the territory
            tile.weight = 1.0 # Reset weight
            tile.territory = null # Clear the territory reference
    
    # Update the territory mesh for the team
    generate()

func generate() -> void:
    pass
