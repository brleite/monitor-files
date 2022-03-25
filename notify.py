import sys
import telegrambot as bot
import json
import os

mensagem = sys.argv[1]

with open(os.path.join(sys.path[0], 'telegrambot.config')) as config_file:
  data = json.load(config_file)

  bot_chatid = data['bot_chatid']
  bot_token = data['bot_token']

  bot.send_message(bot_chatid, bot_token, mensagem)
