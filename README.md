# game_launcher

A flutter project to display and run games.

## Data Preparation

to add a game, you need to add a folder named `data` in the root of the project, and add a json file named `games.json` in it.

The json file should have the following structure:

```json
{
  "games": [
    {
      "name": "Game Name",
      "image": "[path_to_image]",
      "path": "[path_to_game_executable]",
      "metadata": {
        "key": "value",
        ...
      }
    },
    ...
  ]
}
```