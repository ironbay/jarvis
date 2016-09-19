defmodule Bot.Skill.Color do
  use Bot.Skill

  def begin(bot, args) do
    Bot.broadcast(bot, "regex.add", {"(green|red|blue|black|pink|purple)", "color"}) 
  end
end
