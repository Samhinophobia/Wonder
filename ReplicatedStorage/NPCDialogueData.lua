-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")

CurrentDreamStatus.Changed:Connect(function()
	if CurrentDreamStatus.Value == "Convivium Potationis Perpetuum" then
		for _, p in ipairs(Players:GetPlayers()) do
			p:SetAttribute("MomoCountedThisDream", nil)
		end
	end
end)


local function getMomoRole(player)
	local character = player.Character
	local candidates = {
		player:GetAttribute("ActiveMorph"),                    
		character and character:GetAttribute("ActiveMorph"),
		character and character:GetAttribute("ActiveSkin"),    
		character and character.Name,
	}
	for _, value in ipairs(candidates) do
		if typeof(value) == "string" then
			local v = string.lower(value)
			if string.find(v, "karma") then return "Karma" end
			if string.find(v, "patrico") then return "Patrico" end
		end
	end
	return nil 
end

local DialogueData = {

	["MysteriousStranger"] = {
		Portrait = "rbxassetid://123456789", 
		DefaultName = "???",
		GetChat = function(player, talkCount, state)
			local isKarma = (player.Name == "Karma" or player:GetAttribute("ActiveMorph") == "Karma")
			local isPatrico = (player.Name == "Patrico" or player:GetAttribute("ActiveMorph") == "Patrico")
			local currentNPCName = state.NameRevealed and "Alastor" or "???"

			if isKarma then
				return "Ah, <Color=Red>Karma<Color=/>. I was wondering when the Dreamscape would drag you back.", {{Text = "You know me?", Next = "KarmaLore"}}, currentNPCName
			elseif isPatrico then
				return "<Color=Green>Patrico<Color=/>... your presence here destabilizes the realm.", {{Text = "I don't care.", Next = "Close"}}, currentNPCName
			else
				if not state.NameRevealed then
					return "You shouldn't wander in the dark, little dreamer.", {{Text = "Who are you?", Next = "AskName"}, {Text = "I'm leaving.", Next = "Close"}}, currentNPCName
				else
					return "Still here? The shadows are getting longer.", {{Text = "Goodbye.", Next = "Close"}}, currentNPCName
				end
			end
		end,
		Extra = function(player, state)
			return {
				["KarmaLore"] = {Text = "Everyone in the <Color=170,0,255>Frozen Soul<Color=/> knows of you. The script remembers.", Options = {{Text = "Interesting...", Next = "Return"}}, NameOverride = state.NameRevealed and "Alastor" or "???"},
				["AskName"] = {Text = "My name? It's <Color=255,215,0>Alastor<Color=/>. Try not to forget it.", Options = {{Text = "Nice to meet you, Alastor.", Next = "Return"}}, Action = function() state.NameRevealed = true end, NameOverride = "Alastor"}
			}
		end
	},

	["Scarlett"] = {
		Portrait = "rbxassetid://88943499884088",
		DefaultName = "Scarlett",
		GetChat = function(player, talkCount, state)

			local SCAR_SAD = "rbxassetid://81140969795913"
			local SCAR_NEUTRAL = "rbxassetid://111685278715989"
			local SCAR_HAPPY = "rbxassetid://90913332961863"
			local SCAR_ANGRY = "rbxassetid://77043359182734"

			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local sharedCountVal = ReplicatedStorage:FindFirstChild("ScarlettTotalShards")
			local totalShards = sharedCountVal and sharedCountVal.Value or 0

			state.Met = state.Met or false
			state.MemoryGiven = state.MemoryGiven or false

			if not state.Met then
				return "(Tears  in her eyes) I’ve buried enough of Alact's subjects already. I won’t dig another grave today.", {
					{Text = "We’re not with him.", Next = "Realization"}
				}, "Scarlett", SCAR_ANGRY
			end

			if totalShards < 2 then
				return "You’re still wandering blind. Come back when you’ve actually seen something.", {
					{Text = "What do you mean?", Next = "HintShards"},
					{Text = "Leave", Next = "Close"}
				}, "Scarlett", SCAR_NEUTRAL
			end

			if totalShards < 5 then
				return "…You’ve started digging. That’s more than most.", {
					{Text = "I found pieces of your sister.", Next = "ShardDialogue"},
					{Text = "What really happened here?", Next = "PartialLore"},
					{Text = "Leave", Next = "Close"}
				}, "Scarlett", SCAR_SAD
			end

			if not state.MemoryGiven then
				return "…You didn’t just look. You paid attention.", {
					{Text = "Show me the truth.", Next = "GiveMemory"},
					{Text = "Why are you helping us?", Next = "WhyHelp"},
					{Text = "Leave", Next = "Close"}
				}, "Scarlett", SCAR_NEUTRAL
			end

			return "I’ve told you enough. What you do with it is your problem now.", {
				{Text = "Why are you helping us?", Next = "WhyHelp"},
				{Text = "Tell me about the Clockwork City.", Next = "ClockworkCity"},
				{Text = "Leave", Next = "Close"}
			}, "Scarlett", SCAR_NEUTRAL
		end,

		Extra = function(player, state)
			local isKarma = (player.Name == "Karma" or player:GetAttribute("ActiveMorph") == "Karma")
			local isPatrico = (player.Name == "Patrico" or player:GetAttribute("ActiveMorph") == "Patrico")

			local SCAR_SAD = "rbxassetid://81140969795913"
			local SCAR_NEUTRAL = "rbxassetid://111685278715989"
			local SCAR_HAPPY = "rbxassetid://90913332961863"
			local SCAR_ANGRY = "rbxassetid://77043359182734"

			local characterSpecificOption
			if isPatrico then
				characterSpecificOption = {Text = "Will the King stop this?", Next = "PatricoResponse"}
			elseif isKarma then
				characterSpecificOption = {Text = "Why would anyone do that?", Next = "KarmaResponse"}
			else
				characterSpecificOption = {Text = "How do I stop this script?", Next = "GenericResponse"}
			end

			return {
				["Realization"] = {
					Text = "(She lowers her axe.)\n Real eyes... You’re Dreamers. But you wear the Suits. Alice is already writing your endings.",
					Options = {{Text = "What do you mean?", Next = "HintShards"}},
					Portrait = SCAR_NEUTRAL,
					Action = function() state.Met = true end
				},
				["HintShards"] = {
					Text = "Fragments. Pieces of her… scattered through this broken kingdom.\n If you want answers, stop asking me and start looking.",
					Options = {{Text = "Where do I look?", Next = "VagueHint"}},
					Portrait = SCAR_NEUTRAL
				},
				["VagueHint"] = {
					Text = "Anywhere the story feels… wrong.\n Thrones. Gardens. Places that should have mattered.",
					Options = {{Text = "…Alright.", Next = "Close"}},
					Portrait = SCAR_SAD
				},
				["ShardDialogue"] = {
					Text = "Then you’ve seen what they did to her… or at least pieces of it.\nTell me did it look like love to you?",
					Options = {
						{Text = "No.", Next = "ScarlettApproval"},
						{Text = "I don’t know.", Next = "ScarlettNeutral"}
					},
					Portrait = SCAR_SAD
				},
				["ScarlettApproval"] = {
					Text = "…Good. Then you’re not blind.",
					Options = {characterSpecificOption},
					Portrait = SCAR_NEUTRAL
				},
				["ScarlettNeutral"] = {
					Text = "Then look harder next time.",
					Options = {characterSpecificOption},
					Portrait = SCAR_SAD
				},
				["PartialLore"] = {
					Text = "He wasn’t always like this.\n Or maybe he was… and I just didn’t see it.\n\n That’s the problem with stories—they make monsters look like kings.",
					Options = {{Text = "Go back", Next = "Close"}},
					Portrait = SCAR_SAD
				},
				["GiveMemory"] = {
					Text = "…Fine. \nYou’ve earned this much.\n\n But don’t expect it to make sense.",
					Options = {{Text = "Take it.", Next = "MemoryGiven"}},
					Portrait = SCAR_NEUTRAL,
				},
				["MemoryGiven"] = {
					Text = "(She hands you something faintly glowing…)\n Don’t waste it.",
					Options = {{Text = "Leave", Next = "Close"}},
					Portrait = SCAR_SAD,
					Action = function()
						state.MemoryGiven = true
						local ReplicatedStorage = game:GetService("ReplicatedStorage")
						local triggerRemote = ReplicatedStorage:FindFirstChild("DreamEvents"):FindFirstChild("TriggerMemoryOrb")
						if triggerRemote then
							triggerRemote:FireServer()
						end
					end
				},
				["PatricoResponse"] = {
					Text = "Alact isn't in the right mind. Your pain is just poetry to him.\n Stop being predictable.",
					Options = {{Text = "How do I do that?", Next = "FindL"}},
					Portrait = SCAR_NEUTRAL
				},
				["KarmaResponse"] = {
					Text = "You can't protect him from a script.\nPlay that role, and you’ll become the ending.",
					Options = {{Text = "Then how do I save him?", Next = "FindL"}},
					Portrait = SCAR_SAD
				},
				["GenericResponse"] = {
					Text = "You don’t fight a story. You break it.",
					Options = {{Text = "How?", Next = "FindL"}},
					Portrait = SCAR_SAD
				},
				["FindL"] = {
					Text = "Find L. Endless Tea Party.\nThat’s your only chance.",
					Options = {
						{Text = "Why help us?", Next = "WhyHelp"},
						{Text = "Tell me about the tea party.", Next = "ClockworkCity"},
						{Text = "Leave", Next = "Close"}
					},
					Portrait = SCAR_HAPPY
				},
				["WhyHelp"] = {
					Text = "I want someone to remember her as Amaryllis… not as a role.",
					Options = {{Text = "Go back", Next = "Close"}},
					Portrait = SCAR_SAD
				},
				["ClockworkCity"] = {
					Text = "Time doesn’t move right there.\nFind L before something else finds you.",
					Options = {{Text = "Go back", Next = "Close"}},
					Portrait = SCAR_NEUTRAL
				}
			}
		end
	},
	
	
	["Momo"] = {
		Portrait = "rbxassetid://127357356937787",

		DefaultName = "Momo",

		GetChat = function(player, talkCount, state)
			local isKarma = (getMomoRole(player) == "Karma")
			local qState = player:GetAttribute("TeaQuestState") or 0

			-- Count ONE visit per dreamsphere entry, not one per conversation.
			-- MomoCountedThisDream is cleared when the dream ends (see Part 1),
			-- and both attributes vanish when the player leaves the game.
			local visits = player:GetAttribute("MomoVisits") or 0
			if not player:GetAttribute("MomoCountedThisDream") then
				visits += 1
				player:SetAttribute("MomoVisits", visits)
				player:SetAttribute("MomoCountedThisDream", true)
			end

			-- Define expressions
			local Momo_NEUTRAL = "rbxassetid://127357356937787"
			local Momo_SAD = "rbxassetid://130787866470438"
			local Momo_HAPPY = "rbxassetid://83819400984504"
			local Momo_ANGRY = "rbxassetid://94961623242410"

			local text
			local portrait = Momo_NEUTRAL

			if visits == 1 then
				text = "(She doesn't look up immediately.)\n\nYou brought the frost inside. That key was meant to stay buried in the static. Do close the door, the ambient noise of the Tea Party is horribly inefficient."
			elseif visits <= 3 then
				text = "(Her eyes flick up the moment the door closes this time.)\n\nBack again. Either you are lost, or you enjoy hearing the same answers twice. I find repetition tedious. Wonderland already provides enough of it without your help."
			elseif visits <= 6 then
				text = "(She doesn't bother glancing up from the static gathered in her palm.)\n\nI have stopped counting how many times you've stood in that doorway. The number stopped being interesting around the fourth visit. What is it this time."
				portrait = Momo_ANGRY
			else
				text = "(For once, she actually looks at you for a long moment before speaking.)\n\nYou keep returning to a place that offers you nothing new. That is either devotion or a complete failure to learn. I have not yet decided which. Sit, if you intend to waste both our time again."
				portrait = Momo_SAD
			end

			-- Build the base options (one role, one branch -- no mixed chains)
			local options = {}
			if isKarma then
				table.insert(options, {Text = "We didn't come here to steal. Start talking. What is this place?", Next = "Node2K"})
			else
				table.insert(options, {Text = "I'm sorry for intruding. We found the key in a cavern... We just need answers.", Next = "Node2P"})
			end

			-- NOTE: the old "I found a note near the wall..." shortcut is gone.
			-- The note now pays off at the END of the conversation (Node6K/Node6P
			-- lead into GiveBlessingNode), instead of skipping the whole dialog.

			return text, options, "Momo", portrait
		end,

		Extra = function(player, state)
			local isKarma = (getMomoRole(player) == "Karma")
			local qState = player:GetAttribute("TeaQuestState") or 0

			local Momo_NEUTRAL = "rbxassetid://127357356937787"
			local Momo_SAD = "rbxassetid://130787866470438"
			local Momo_HAPPY = "rbxassetid://83819400984504"
			local Momo_ANGRY = "rbxassetid://94961623242410"

			-- The finale is gated behind the note: without it, Momo refuses to
			-- hand out the directions and points the player toward the wall.
			local finaleNode = isKarma and "Node6K" or "Node6P"
			local finaleNext = (qState >= 1) and finaleNode or "NodeNotReady"

			-- After the finale: if the player is carrying the note (qState == 1),
			-- the conversation flows into GiveBlessingNode. Once the blessing is
			-- given (server should set TeaQuestState to 2), it reverts to [Leave].
			local finaleOptions = (qState == 1)
				and {{Text = "Before I go... I found a note near the wall.", Next = "GiveBlessingNode"}}
				or  {{Text = "[Leave]", Next = "Close"}}

			return {
				-- [[ QUEST NODE -- now reached FROM Node6K/Node6P, not from the greeting ]]
				["GiveBlessingNode"] = {
					Text = "(She glances at the note, her expression barely flickering.)\n\nSo, you've decided to interfere with the clockwork. Very well. Take this blessing -- it is the only thing that will allow you to interact with the static.",
					Options = {{Text = "Thank you.", Next = "Close"}},
					Portrait = Momo_HAPPY,
					Action = function()
						local rs = game:GetService("ReplicatedStorage")
						local de = rs:FindFirstChild("DreamEvents")
						if de and de:FindFirstChild("MomoBlessingEvent") then
							de.MomoBlessingEvent:FireServer()
						end
					end
				},

				-- [[ NOT READY: shown when the player reaches the finale without the note ]]
				["NodeNotReady"] = {
					Text = "(She studies you for a long moment, then snaps her pocket watch shut.)\n\nNo. Not yet. The border will not open for someone the static does not recognize. There is a wall in this dream that has been listening to you since you arrived. Something was left near it. Find it, bring me what you find, and then we will discuss matches.",
					Options = {{Text = "[Leave]", Next = "Close"}},
					Portrait = Momo_NEUTRAL
				},

				["Node2P"] = {
					Text = "An apology is an inefficient use of breath, Blankborn. You apologize for opening a wooden door, yet you shattered the Card Kingdom to get here. Your existence is a contradiction the Author cannot parse.",
					Options = {
						{Text = "You know what we are. Why haven't you turned us in?", Next = "Node3P"},
						{Text = "You know about the frozen castle. Nivalis.", Next = "Node4Intro"},
						{Text = "We're looking for someone named L.", Next = "Node5"},
						{Text = "Why does your watch never match the time here?", Next = "NodeWatch"}
					},
					Portrait = Momo_NEUTRAL
				},

				["Node2K"] = {
					Text = "(She sighs, closing her pocket watch with a sharp click.)\n\nYou bark at the walls hoping the house will flinch. You are a Blankborn, yet you think like a cornered animal. Lower your shoulders. If I wanted to alert the Hatter to your presence, you would already be shredded.",
					Options = {
						{Text = "Then why haven't you? Scarlet called us Blankborns.", Next = "Node3K"},
						{Text = "This key unlocked your door. We found it in a collapsed ice cavern.", Next = "Node4Intro"},
						{Text = "We need to find L. Tell me where he is.", Next = "Node5"},
						{Text = "Why does your watch never match the time here?", Next = "NodeWatch"}
					},
					Portrait = Momo_SAD
				},

				-- [[ THE WATCH ]]
				["NodeWatch"] = {
					Text = "(She glances down at it as though you've pointed out something rude.)\n\nIt does not malfunction. It simply refuses to agree with a clock the Author keeps rewinding. Time here is a suggestion, not a constant. Mine remembers what actually happened. Most Dreamers find that an uncomfortable thing to stand near.",
					Options = isKarma
						and {
							{Text = "Then why haven't you? Scarlet called us Blankborns.", Next = "Node3K"},
							{Text = "This key unlocked your door. We found it in a collapsed ice cavern.", Next = "Node4Intro"},
							{Text = "We need to find L. Tell me where he is.", Next = "Node5"}
						}
						or {
							{Text = "You know what we are. Why haven't you turned us in?", Next = "Node3P"},
							{Text = "You know about the frozen castle. Nivalis.", Next = "Node4Intro"},
							{Text = "We're looking for someone named L.", Next = "Node5"}
						},
					Portrait = Momo_NEUTRAL
				},

				["Node3P"] = {
					Text = "Because I do not align with the system, Patrico. I align with progress. The Hatter runs in circles. The Dreamers panic. But you... Wonderland literally struggles to process you. I hate unpredictability, but right now, you are the only variable moving the plot forward. Do not mistake my observation for friendship.",
					Options = {
						{Text = "You know about the frozen castle. Nivalis.", Next = "Node4Intro"},
						{Text = "We're looking for someone named L.", Next = "Node5"},
						{Text = "Scarlett says you could have saved her sister. Is that true?", Next = "NodeScarlettConfront"}
					},
					Portrait = Momo_NEUTRAL
				},

				["Node3K"] = {
					Text = "Because you are currently useful. You are Blankborns, yes. Unfinished people occupying space that refuses to fit. To most, you are a contaminant. To me, you are a wedge in the door. The Hatter wants you deleted, but your absolute refusal to die is breaking the loop. Keep breaking it, and I will keep quiet.",
					Options = {
						{Text = "This key unlocked your door. We found it in a collapsed ice cavern.", Next = "Node4Intro"},
						{Text = "We need to find L. Tell me where he is.", Next = "Node5"},
						{Text = "Scarlett says you could have saved her sister. Is that true?", Next = "NodeScarlettConfront"}
					},
					Portrait = Momo_NEUTRAL
				},

				-- [[ THE SCARLETT CONFRONTATION ]]
				["NodeScarlettConfront"] = {
					Text = "(A pause, fractionally longer than her usual silences.)\n\nYes. I could have intervened. I chose not to. Amaryllis's death was the only event capable of breaking Alact from his role entirely -- and it did. Scarlett mistakes restraint for cruelty. I do not enjoy the math. I simply do not pretend the math isn't there.",
					Options = isKarma
						and {
							{Text = "This key unlocked your door. We found it in a collapsed ice cavern.", Next = "Node4Intro"},
							{Text = "We need to find L. Tell me where he is.", Next = "Node5"}
						}
						or {
							{Text = "You know about the frozen castle. Nivalis.", Next = "Node4Intro"},
							{Text = "We're looking for someone named L.", Next = "Node5"}
						},
					Portrait = Momo_NEUTRAL
				},

				["Node4Intro"] = {
					Text = "(Her voice drops slightly, losing a fraction of its cold edge. She stares at the key in your hand.)\n\nYou walked through the Weeping Castle. You saw the tomb at the bottom of the cavern... Did it still burn?",
					Options = isKarma
						and {{Text = "It was a death trap. Something was watching us in the dark. Smiling.", Next = "Node4K"}}
						or  {{Text = "It felt... sad. Like someone was crying but couldn't make a sound.", Next = "Node4P"}},
					Portrait = Momo_SAD
				},

				["Node4P"] = {
					Text = "She traded a fever for a blizzard, hoping for relief... I watched my child freeze because I tried to calculate a cure instead of breaking the script. You pity the Casters, Patrico. I see it in you. That pity will kill you, just as my logic killed her.",
					Options = {
						{Text = "We're looking for someone named L.", Next = "Node5"},
						{Text = "You loved her, didn't you?", Next = "NodeSeraphinaDeep"}
					},
					Portrait = Momo_SAD
				},

				-- [[ SERAPHINA, IN FULL ]]
				["NodeSeraphinaDeep"] = {
					Text = "(Her voice drops further. Not dramatically -- just quieter, the way a room goes quiet when something fragile is being carried through it.)\n\nLove is an inefficient word for it. She called me 'Momo' before anyone else did. She was the only person in this fog who ever needed me for a reason that wasn't strategic. I was supposed to find her a cure. I found an equation instead.\n\n(She closes the pocket watch, hard, and does not open it again for the rest of the conversation.)\n\nI have not made that particular mistake again.",
					Options = {
						{Text = "We're looking for someone named L.", Next = "Node5"}
					},
					Portrait = Momo_SAD
				},

				["Node4K"] = {
					Text = "(Momo's posture stiffens abruptly, a rare crack in her absolute composure. She lowers her voice.)\n\nThere are... anomalies that wander the dead drafts. Things that do not have names, only teeth. They are not to be spoken of. If you saw a smile in the static and survived, your brother's luck is the only reason. Do not go back there.",
					Options = {
						{Text = "We need to find L. Tell me where he is.", Next = "Node5"},
						{Text = "What kind of anomalies. Be specific.", Next = "NodeAnomalyDeep"}
					},
					Portrait = Momo_ANGRY
				},

				-- [[ THE DEAD DRAFTS ]]
				["NodeAnomalyDeep"] = {
					Text = "(Momo's jaw tightens slightly -- as close to hesitation as you have seen from her.)\n\nWhen the Author deletes something, it rarely disappears cleanly. Sometimes it lingers as residue -- quiet, harmless, little more than static. Sometimes it lingers because it does not know it was supposed to stop existing, and it is furious about the implication. The second kind is what watched you in that cavern. I would not go looking for a name. Naming it tends to be the last mistake anyone makes.",
					Options = {
						{Text = "We need to find L. Tell me where he is.", Next = "Node5"}
					},
					Portrait = Momo_ANGRY
				},

				["Node5"] = {
					Text = "L does not stay in one place. He uses the blind spots. He is the one who killed the Frost Queen of Nivalis... to save her. L understands that to save someone in Wonderland, you must destroy their role. If you want his help, you must be willing to burn your own script. And to do that, you must move deeper into the rot.",
					Options = isKarma
						and {
							{Text = "If destroying the script saves my brother, hand me the match.", Next = finaleNext},
							{Text = "What's between you and the Hatter?", Next = "NodeHatterRivalry"}
						}
						or {
							{Text = "I'll do whatever it takes to get Karma out. Even if I stay behind.", Next = finaleNext},
							{Text = "What's between you and the Hatter?", Next = "NodeHatterRivalry"}
						},
					Portrait = Momo_NEUTRAL
				},

				-- [[ THE HATTER RIVALRY ]]
				["NodeHatterRivalry"] = {
					Text = "He remembers enough of the truth to suffer, and not enough to act on it. That combination is, in my professional opinion, the most dangerous thing a person can become -- aware just enough to know they are trapped, sane enough to keep performing anyway. I am not interested in becoming him. He is not interested in becoming honest. We have reached, over many loops, a stable equilibrium of mutual avoidance.",
					Options = isKarma
						and {{Text = "If destroying the script saves my brother, hand me the match.", Next = finaleNext}}
						or  {{Text = "I'll do whatever it takes to get Karma out. Even if I stay behind.", Next = finaleNext}},
					Portrait = Momo_NEUTRAL
				},

				["Node6P"] = {
					Text = "(Leans forward, her eyes entirely devoid of sympathy.)\n\nAnd there is the flaw in your code. You think self-destruction is the same thing as victory. If you erase yourself to save her, the Author will simply write her a chapter entirely about grief. If you want to find L, you must leave this loop. Go to the center of the Tea Party and find the grandfather clock that ticks backwards. Shattering it will tear the border open, dropping you into the Mushroom Forest. But remember, Patrico... a martyr is just an actor who dies on cue.",
					Options = finaleOptions,
					Portrait = Momo_ANGRY
				},

				["Node6K"] = {
					Text = "(A faint, almost imperceptible smirk crosses her face.)\n\nYou would burn the entire book if it kept him warm. It is highly inefficient, but remarkably effective. If you want to find L, you must force a path forward. Go to the center of the Tea Party. Find the grandfather clock that ticks backwards and break the glass. It will shatter the local loop and drop you into the Mushroom Forest. L will be waiting in the rot.",
					Options = finaleOptions,
					Portrait = Momo_HAPPY
				}
			}
		end
	}
}

	return DialogueData