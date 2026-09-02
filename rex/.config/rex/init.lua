-- Rex config: https://www.superlogical.com/rex/docs/customize/config.md
rex.bind("cmd+e", "pane.zoom")
rex.bind("cmd++", "client.font.increase")
rex.bind("cmd+-", "client.font.decrease")
rex.bind("cmd+0", "client.font.reset")

rex.mode("resize", { exclusive = true })
rex.bind("cmd+r", "client.mode.enter", { name = "resize" })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })

-- Hold shift for bigger steps
rex.bind("resize/shift+left", "pane.resize", {
	direction = "left",
	amount = 15,
})
rex.bind("resize/shift+right", "pane.resize", {
	direction = "right",
	amount = 15,
})

rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
