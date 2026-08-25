-- @ScriptType: ModuleScript
local InteractionData = {}


InteractionData.MAX_INTERACT_DISTANCE = 35
InteractionData.MAX_CAMERA_ZOOM_DIST = 17
InteractionData.FEMALE_TORSO_ID = "48474356"


InteractionData.SHIRT_GENDERS = {
	[13517513214] = "Male", 
	[71863730807750] = "Female", 
	[107868623831746] = "Male", 
	[121349483867776] = "Female", 
	[12188127305] = "Male", 
	[17390381789] = "Female",

}


InteractionData.VIP_QUOTES = {
	[4477038552] = { 
		Normal = { Male = "Oh that outfit is quite questionable...", Female = "I wonder where he got those clothes..." },
		Dream = { Male = "That's the King of the Card Kingdom.", Female = "That's the Emperor of the Card Kingdom." }
	},
	[3457196097] = { 
	--	Normal = { Male = "Oh that outfit is quite questionable...", Female = "I wonder where he got those clothes..." },
		Dream = { Male = "Every time I see you... it feels like I'm the one arriving late.", Female = "You smile like someone watching a play for the second time." }
	},
	[885558216] = { 
		Normal = { Male = "He looks a bit lost.", Female = "Is he lost?" },
		Dream = { Male = "The Hatter looks busy.", Female = "The Hatter looks busy." }
	}
}


InteractionData.SPECIAL_RELATIONSHIPS = {
	[885558216] = { [4477038552] = { Normal = "Your Majesty, you're late for tea!", Dream = "The crown suits you better here, sir." }, [3457196097] = {
		Normal = "Ahh, the punctual rabbit arrives precisely when expected.",
		Dream = "Careful, little observer. Even perfect memory becomes madness if wound too tightly."
	} },
	[4477038552] = { [885558216] = { Normal = "Off with his... hat?", Dream = "Back to work, Hatter." } },
	-- MOMO -> HATTER
	[3457196097] = {
		[998312441] = {
			Normal = "Your clocks are drifting again.",
			Dream = "One day your little machine will choke on its own loops."
		},
		[4477038552] = {
			Normal = "Something is different about you.",
			Dream = "I wonder which version of 'Alact' you are"
		},
	}
}


InteractionData.VIP_OUTFIT_REACTIONS = {
	[4477038552] = { 
		[13776425493] = "Stand tall, soldier. We have a kingdom to guard.",
		[13517513214] = "Paint me a rose, artist. Make it red.",
		[71863730807750] = "If I see a single drop of white paint, it's off with your head!",
		[121349483867776] = "Another wanderer? Be careful here.",
		[107868623831746] = "You reek of bad luck, Stay away."
	},
	[885558216] = { 
		[13776425493] = "Careful! Don't crease your corners!",
		[121349483867776] = "You look dreadfully normal. Have some tea?",
		[13517513214] = "A painter! Can you paint me a tea set that never runs dry?",
		[71863730807750] = "Too much Black and White! We need more... purple! Or perhaps green tea?",
		[107868623831746] = "Not enough time in the world for you I can tell."
	}
}


InteractionData.OUTFIT_REACTIONS = {


	[107868623831746] = { -- Male Only
		MaleViewer = "Another dull moment, Was I always this bad..", 
		FemaleViewer = "I wish my brother would speak more..",
		Self = "Is that... me?"
	},
	[387223743] = { -- Emp Rico
		MaleViewer = "I always knew I was a bad omen, But I thought I'd never go this far.", 
		FemaleViewer = "That's not the brother I knew..",
		Self = "Is that... me?"
	},
	[121349483867776] = { -- Female Only
		MaleViewer = "My sister she's always happy, good for her...", 
		FemaleViewer = "Is that... me? I look normal.",
		Self = "It's like looking in a mirror."
	},

	[12188127305] = { -- Male Only Love Varient
		MaleViewer = "It’s a cruel holiday for a curse like me. My heart isn't a gift you give to someone, it's a grenade. I’d be safer alone.", 
		FemaleViewer = "Don't look at the paper hearts, Patrico. In this world, the only heart that matters is the one I’m keeping safe in your chest.",
		Self = "Is that... me?"
	},
	[17390381789] = { -- Female Only Love Varient
		MaleViewer = "I’m sorry your heart has to be a shield for mine, Karma. You deserve flowers, not a funeral march", 
		FemaleViewer = "I never really had a childhood. I just had a head start on worrying.",
		Self = "It's like looking in a mirror."
	},


	[13517513214] = { -- Male Only Artist
		MaleViewer = "I didn't know I had the talent to paint.",
		FemaleViewer = "I didn't know my brother could paint, I knew if he tried he could be the best.",
		Self = "Time to make some art."
	},
	[71863730807750] = { -- Female Only Artist
		MaleViewer = "My sister always knew how to be the best at anything.",
		FemaleViewer = "I look like I'm ready for college!",
		Self = "I feel creative today."
	},
	[7155058745] = { -- Male Only Endless
		MaleViewer = "I've walked this route before. The fog keeps showing me the same trees. I'm starting to think the loop is trying to teach me something I'm too stubborn to learn.",
		FemaleViewer = "He walks through this forest like he's reading a book he's already finished. I don't know if he's losing his mind or if he's the only one here who hasn't.",
		
	},
	[6054564605] = { -- Female Only Endless
		MaleViewer = "I really wish I could tell you...",
		FemaleViewer = "My hands know what to do before my head catches up. I keep reaching for things that aren't there yet, like my body is rehearsing for a play I don't remember auditioning for.",

	},
	
	[18609993045] = {
		-- Target is MALE
		TargetMale_MaleViewer = "I keep thinking if I sit still long enough, This place will remember me for something good.", 
		TargetMale_FemaleViewer = "Every version of you finds a new way to worry me.", 

		-- Target is FEMALE
		TargetFemale_MaleViewer = "You hold my arm tighter in this place, Like you're scared I'll disappear if you stop.", 
		TargetFemale_FemaleViewer = "I keep preparing for things that already happened.", 

		-- Clicking Self
		Self = "I feel stronger in this armor."
	},

	[13776425493] = {
		-- Target is MALE
		TargetMale_MaleViewer = "Since when was I, A Card Soldier?", 
		TargetMale_FemaleViewer = "You look like a masterpiece, But all I see is a beautiful frame where my brother used to be.", 

		-- Target is FEMALE
		TargetFemale_MaleViewer = "You look like a funeral for a tragedy I haven't even finished causing yet.", 
		TargetFemale_FemaleViewer = "Since when was I, A Card Soldier?", 

		-- Clicking Self
		Self = "I feel stronger in this armor."
	},


	["DEFAULT"] = {
		MaleViewer = "They look familiar...",
		FemaleViewer = "I feel like I know them...",
		Self = "Do I know you?"
	}
}



InteractionData.NOTES = {
	["KingSecret"] = {
		Title = "The Red Static",
		Subject = "Alaric | The King of Hearts",
		Target = "Observation",
		Body = "I tried to noclip through the outer wall. Bad idea. The [XXX] hit me instantly. I found myself laughing wildy while my body began to rot. It takes away your control."
	},

	["HeartsDream"] = {
		Title = "The Red Static",
		Subject = "Alaric | The King of Hearts",
		Target = "Regnum Chartarum",
		Body = "The King isn't just a boss, he’s the entire server. His grief is rewriting the dreamsphere itself and of anyone who enters. If I stayed for five more minutes, I would have become a 'Joker' card in his deck permanently."
	},

	["ClockObvs"] = {
		Title = "The Gear Grind",
		Subject = "Vane | The Mad Hatter",
		Target = "Observation",
		Body = "The speed in there is too fast. I watched a bird fly into a clock tower and age into dust before it hit the ground."
	},
	["HeartsAdvice"] = {
		Title = "The Red Static",
		Subject = "Alaric | The King of Hearts",
		Target = "Tips",
		Body = "Threat Level, Impossible. You can't destroy a delusion that defends itself with happiness. Do Not Engage. Keep a minimum distance of 500 meters from the castle. If you do enter his realm do NOT trust him."
	},
	["Karma&Patrico"] = {
		Title = "Tourists",
		Subject = "Patrico & Karma",
		Target = "Mr. W",
		Body = "I saw them heading toward the Card Kingdom. Idiots. They think they can 'talk' to HIM. They’re going to get eaten alive. I’ll prepare the obituary."
	},
	["Liber"] = {
		Title = "Sector Zero",
		Subject = "Refuge",
		Target = "Mr. W",
		Body = "The other dreamsphere are loud. But here... the owner is Dead. It was a tough battle but, I hate how she look at me before I snapped her neck. Mr. W I'll be staying here to recover my mental state before I'll accept anymore of your stupid request."
	},
	["Her"] = {
		Title = "Why",
		Subject = "Sickness",
		Target = "To XXX",
		Body = "The fever won't stop. Even in the dream, I can feel the burning. I built these walls to keep the heat out, But I'm melting from the inside. The stranger is watching me from the doorway I've been defending myself from his ambushes. He doesn't look like a doctor he states he's a dreamer I thought about making a trap for him but, He asked me if I wanted the pain to end and wake up from false reality, or if I wanted to keep dueling with him until my last limb. I told him I was too tired to wake up. He smiled. He said he knows how to make the cold permanent. Please... just make it stop."
	},
	["HatterNote"] = {
		Title = "To My Guest",
		Subject = "Tea Party.",
		Target = "To XXX",
		Body = "To my most punctual guests, If the clock refuses to open its teeth, then you are likely listening to time instead of hosting it. A table is not entered from the front. Tea is not poured from a full cup. And clocks, naturally, are most honest when they are wrong. Some guests insist the little hand matters most. Fools. The little hand merely waits."
	},
	["HatterNote2"] = {
		Title = "To My Guest",
		Subject = "The Clock.",
		Target = "To XXX",
		Body = "The Host once claimed there were four directions. Ridiculous. There are only three, Forward. Backward. And deeper. The guests who walked forward vanished into fog. The guests who walked backward returned unchanged. But the guests who walked deeper.. Well who knows what happened to them."
	},
	["MomoNote"] = {
		Title = "The Endless Tea Party",
		Subject = "The Hatter's Heart.",
		Target = "To L",
		Body = "I finally understood why nobody solves the clock. They keep searching for the correct time. But this place does not care about correctness. It cares about repetition. Every loop begins the same way: Tea. Conversation. Forgetting. The first cup is always poured when the long hand points down. Not midnight. Not noon. The hour beneath conversation. The hidden guests opened the path when both hands stopped pretending to move forward."
	},
	["Patrico"] = {
		Title = "What I could've been",
		Subject = "Wonderland",
		Target = "To XXX",
		Body = "I woke up and the world didn't end. You did. There's still a place for you next to me. I haven't touch it, I think if I do, You'll be gone for real. You fixed everything. So why not this? They say it wasn't my fault. But you stayed when I didn't choose you. You stayed anyway. And I let you, If I haven't gone here. If I was more independent you'd be someone our parents would be proud of."
	},
	["Cat"] = {
		Title = "The Cheshire Cat",
		Subject = "My Daughter",
		Target = "XXX",
		Body = "I stitched her together from the shadows of the other dreams. I gave her a smile that doesn't reach her eyes, and a body that dissolves into smoke whenever someone tries to touch her. She is my Spy. My little ghost. She wanders through the walls of the Card Kingdom and the Endless Tea Party, listening to the secrets the other Casters try to hide from me. Oh my little perfect liar..."
	}
}


InteractionData.MEMORIES = {

	["Curse"] = {
		Soundtrack = "rbxassetid://126343355393678", 
		SoundtrackVolume = 0.6,
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "My lungs are bleeding again.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			--Image = "rbxassetid://6746654784", -- Scene 1 Continues
			Segments = {
				{ text = "The thorns are growing thicker.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
	--		Image = "rbxassetid://6746654784", -- Scene 1 Continues
			Segments = {
				{ text = "I know I don't have much time left...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
		--	Image = "rbxassetid://6746654784", -- Scene 1 Continues
			Segments = {
				{ text = "Before the flowers tear my throat apart entirely.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
		--	Image = "rbxassetid://7377196025", -- Scene 2: Crossfades to a new Image!
			Segments = {
				{ text = "I had to make my move.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
	--		Image = "rbxassetid://7377196025", -- Scene 2 Continues
			Segments = {
				{ text = "I found ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "Alact", color = Color3.fromRGB(255, 50, 50), shake = true },
				{ text = " in the throne room.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
	--		Image = "rbxassetid://7377196025", -- Scene 2 Continues
			Segments = {
				{ text = "I didn't care who was listening.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			-- Notice no 'Image =' here! This smoothly fades back to the default Blur.
			Segments = {
				{ text = "I begged him. I looked him in his eyes...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "And I lied to him.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "I'm not asking you to live happily ever after with me,", color = Color3.fromRGB(170, 0, 0) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Alact!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "I'm asking you to run away from this Dreamscape...", color = Color3.fromRGB(170, 0, 0) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Together with me!", color = Color3.fromRGB(170, 0, 0) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "As if the story of this place ever benefited anyone?!", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "We do everything we do for the sake of ", color = Color3.fromRGB(170, 0, 0), shake = true },
				{ text = "Alice's", color = Color3.fromRGB(200, 100, 255), shake = true }, 
				{ text = " play!", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150), 
			Segments = {
				{ text = "But, I-", color = Color3.fromRGB(255, 255, 127), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Don't ask me if this is about ", color = Color3.fromRGB(170, 0, 0) },
				{ text = "LOVE", color = Color3.fromRGB(255, 255, 127), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "I can't answer that! I just know, ", color = Color3.fromRGB(170, 0, 0), shake = true },
				{ text = "Alact...", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Out there we'd be happy. We'll have something real...", color = Color3.fromRGB(170, 0, 0) }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Something this Dreamscape can't produce...", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "Something not even ", color = Color3.fromRGB(170, 0, 0), shake = true },
				{ text = "Alice", color = Color3.fromRGB(200, 100, 255), shake = true },
				{ text = " could...", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Segments = {
				{ text = "SHUT UP!", color = Color3.fromRGB(200, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Segments = {
				{ text = "I don't exist in the real world, ", color = Color3.fromRGB(170, 0, 0), shake = true },
				{ text = "Amaryllis.", color = Color3.fromRGB(100, 200, 255), shake = true } 
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Segments = {
				{ text = "I can't be human like I used to...", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Segments = {
				{ text = "I can't be you. I'm long deceased...", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Amaryllis",
			SpeakerColor = Color3.fromRGB(255, 255, 255),
			Segments = {
				{ text = "JUST WHY AM I IN THIS HELL?!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		}
	},
	["SeraphinaFever"] = {
		Soundtrack = "rbxassetid://126343355393678",
		SoundtrackVolume = 0.6,


		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "Mother... please.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "The ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "ice", color = Color3.fromRGB(100, 200, 255) },
				{ text = " isn't working anymore.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I can feel the ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "fever", color = Color3.fromRGB(255, 100, 50), shake = true },
				{ text = " boiling underneath my skin again.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "It's ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "melting", color = Color3.fromRGB(255, 150, 50) },
				{ text = " the throne room... I can't...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I can't endure this ", color = Color3.fromRGB(200, 200, 200), shake = true },
				{ text = "heat", color = Color3.fromRGB(255, 50, 50), shake = true },
				{ text = " anymore!", color = Color3.fromRGB(200, 200, 200), shake = true }
			}
		},


		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Oh, my sweet, dramatic little ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "ember.", color = Color3.fromRGB(255, 100, 50) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Look at you shivering.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "The contrast between your burning soul", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "and these frozen walls..", color = Color3.fromRGB(0, 255, 255) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "It's breathtaking.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "The lighting in here is simply perfect.", color = Color3.fromRGB(200, 200, 200) }
			}
		},


		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I'm not asking for beauty! ", color = Color3.fromRGB(200, 200, 200), shake = true },
				{ text = "I'm asking for a cure!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "Please, ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "Mother...", color = Color3.fromRGB(200, 100, 255) },
				{ text = " just let me sleep.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "Cut this ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "fire", color = Color3.fromRGB(255, 50, 50), shake = true },
				{ text = " out of my chest.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "Let me go completely ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "numb.", color = Color3.fromRGB(100, 200, 255) }
			}
		},


		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "*Sigh*... But darling,", color = Color3.fromRGB(150, 150, 150) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "What is an Ice Kingdom", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "without a tragic, burning Queen...", color = Color3.fromRGB(255, 100, 50) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "...freezing at its center?", color = Color3.fromRGB(100, 200, 255) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "If you go completely numb, there’s no conflict.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "The audience won't feel sorry for you.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "They’ll just be bored.", color = Color3.fromRGB(200, 200, 200) }
			}
		},


		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I don't care about your audience!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "It hurts! It hurts so much, ", color = Color3.fromRGB(255, 50, 50), shake = true },
				{ text = "Mother!", color = Color3.fromRGB(200, 100, 255), shake = true }
			}
		},
		{
			Speaker = "Seraphina",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I'm begging you!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},


		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Growing pains, my dear. That’s all.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "If I put out your ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "fire", color = Color3.fromRGB(255, 100, 50) },
				{ text = " completely...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You’d just be a block of ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "ice.", color = Color3.fromRGB(100, 200, 255) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "And I don't play with ice cubes.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Now... dry your tears.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "The ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "frost", color = Color3.fromRGB(100, 200, 255) },
				{ text = " looks so pretty against your flushed cheeks.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Be a good girl and go sit on your throne.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "The show is about to start.", color = Color3.fromRGB(200, 200, 200) }
			}
		}
	},
	["Karma"] = {
		Soundtrack = "rbxassetid://126343355393678", 
		SoundtrackVolume = 0.6,
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "A whole garden of flowers…", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "And there’s my name on a rock.", color = Color3.fromRGB(170, 0, 0) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "I shouldn’t have followed him into Wonderland.", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "I knew the ending...", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = " I just thought I could write a better one for him.", color = Color3.fromRGB(150, 100, 200) }
			}
		},


		{
			Speaker = "Patrico",
			SpeakerColor = Color3.fromRGB(255, 85, 0),
			Segments = {
				{ text = "...Karma?", color = Color3.fromRGB(170, 85, 0), shake = true }
			}
		},


		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "Don’t use that voice.", color = Color3.fromRGB(255, 255, 255) },
				{ text = " It doesn't belong to you anymore.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Patrico",
			Segments = {
				{ text = "I thought you—", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "Died?", color = Color3.fromRGB(85, 0, 0), shake = true },
				{ text = " Yeah. I did.", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "On the cold floor,", color = Color3.fromRGB(255, 255, 255) }
				--	{ text = " Waiting for footsteps that never came.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "Waiting for footsteps that never came.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},


		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(170, 85, 0),
			Segments = {
				{ text = "You saved yourself.", color = Color3.fromRGB(255, 255, 255) },
				{ text = " You chose the exit.", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "And I was just the door you locked behind you.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Patrico",
			Segments = {
				{ text = "I tried to get to you, I swear I—", color = Color3.fromRGB(255, 255, 255), shake = true }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "Stop lying to a ghost, Patrico.", color = Color3.fromRGB(255, 255, 255) },
				{ text = " It’s insulting.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},


		{
			Speaker = "Karma",
			Segments = {
				{ text = "I poured myself empty just to keep you whole.", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "I stayed through the grief of OUR parents.", color = Color3.fromRGB(85, 0, 0) }
				--	{ text = " I stayed through the neglect.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Karma",
			Segments = {
				--	{ text = "I stayed through the grief of OUR parents.", color = Color3.fromRGB(85, 0, 0) },
				{ text = "I stayed through the neglect.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},



		{
			Speaker = "Patrico",
			Segments = {
				{ text = "BECAUSE I’M NOTHING WITHOUT YOU!", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},
		{
			Speaker = "Patrico",
			Segments = {
				{ text = "IS THAT WHAT YOU WANT TO HEAR?", color = Color3.fromRGB(255, 100, 100), shake = true }
			}
		},
		{
			Speaker = "Patrico",
			Segments = {
				{ text = "You were the only person that made me...", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Patrico",
			Segments = {
				{ text = "Feel like a human!", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},


		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(120, 120, 120),
			Segments = {
				{ text = "Listen to yourself.", color = Color3.fromRGB(150, 150, 150) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "Even now, with my blood on your hands...", color = Color3.fromRGB(85, 0, 0) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "It’s still about YOUR grief.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "Name one thing you loved about me...", color = Color3.fromRGB(255, 255, 255) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "That wasn't a way I served you.", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},


		{
			Speaker = "Patrico",
			Segments = {
				{ text = "...", color = Color3.fromRGB(255, 255, 255) }
			}
		},


		{
			Speaker = "Karma",
			SpeakerColor = Color3.fromRGB(150, 200, 255),
			Segments = {
				{ text = "I didn’t need a savior, Patrico.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "I just needed to be worth the choice.", color = Color3.fromRGB(150, 200, 255), shake = true }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "Just once, I wanted to understand you.", color = Color3.fromRGB(255, 255, 255) }
			}
		},


		{
			Speaker = "Karma",
			Segments = {
				{ text = "Learn how to choose the next one.", color = Color3.fromRGB(255, 255, 255), shake = true }
			}
		},
		{
			Speaker = "Karma",
			Segments = {
				{ text = "Don’t let my ghost be the only thing you ever truly held dear.", color = Color3.fromRGB(255, 255, 255) }
			}
		}
	},

	["LadyAda"] = {
		Soundtrack = "rbxassetid://126343355393678", 
		SoundtrackVolume = 0.6,

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You’ve been unusually ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "quiet ", color = Color3.fromRGB(200, 100, 255) },
				{ text = "today.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "There is nothing to report, Mother.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Mm.", color = Color3.fromRGB(150, 150, 150) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "That’s strange.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Because I’ve been ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "watching you.", color = Color3.fromRGB(200, 100, 255), shake = true }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "Then you already know everything.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Not everything.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Just the parts you try to ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "hide.", color = Color3.fromRGB(200, 100, 255) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You’ve been leaving your Dreamsphere.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "Observation improves accuracy.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Observation.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You watch something ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "break.", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You watch it ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "linger.", color = Color3.fromRGB(150, 150, 150) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "And you don’t look away.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "It is inefficient to interfere.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "No.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "It’s because you’re ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "interested.", color = Color3.fromRGB(200, 100, 255) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "Incorrect.", color = Color3.fromRGB(200, 200, 200), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Then why didn’t you ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "correct it?", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "You correct everything else.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "It is not mine to correct.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Oh, Ada…", color = Color3.fromRGB(150, 150, 150) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Since when has that ever stopped you?", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Say it.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "What is it to you?", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "Nothing, Mother.", color = Color3.fromRGB(200, 200, 200), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Good.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Then you won’t mind if I ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "rewrite it.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "...", color = Color3.fromRGB(85, 0, 0), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Or perhaps...", color = Color3.fromRGB(150, 150, 150) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "I should ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "replace ", color = Color3.fromRGB(170, 0, 0), shake = true },
				{ text = "you instead.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Ada",
			SpeakerColor = Color3.fromRGB(180, 220, 255),
			Segments = {
				{ text = "Understood, Mother.", color = Color3.fromRGB(150, 150, 150), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Good.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Segments = {
				{ text = "Remember your place.", color = Color3.fromRGB(170, 0, 0), shake = true }
			}
		}
	},


	["AlactDespair"] = {
		Soundtrack = "126343355393678", -- Starting sad music
		SoundtrackVolume = 0.6,

		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150), 
			Image = "rbxassetid://135181529259042",
			Segments = {
				{ text = "The ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "flowers ", color = Color3.fromRGB(170, 0, 0), shake = true, Pause = 0.5 },
				{ text = "stopped...", color = Color3.fromRGB(200, 200, 200), TypeSpeed = 0.1 } -- Slower typing for sadness
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://135181529259042",
			Segments = {
				{ text = "She's ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "gone, ", color = Color3.fromRGB(255, 50, 50), shake = true, Pause = 0.5 },
				{ text = "Alice.", color = Color3.fromRGB(200, 100, 255) }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://135181529259042",
			Segments = {
				{ text = "Please. I can't do this anymore.", color = Color3.fromRGB(200, 200, 200), Pause = 1 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://135181529259042",
			Segments = {
				{ text = "I don't want to wear this ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "crown.", color = Color3.fromRGB(255, 215, 0) } 
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://135181529259042",
			Segments = {
				{ text = "I don't want to be ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "Alact.", color = Color3.fromRGB(255, 50, 50), shake = true }
			}
		},

		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "*Sigh*... ", color = Color3.fromRGB(150, 150, 150), Pause = 1 },
				{ text = "Oh, dry your eyes...", color = Color3.fromRGB(150, 150, 150) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Your Majesty.", color = Color3.fromRGB(255, 215, 0) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "You're getting the floorboards wet.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "We have a ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "schedule ", color = Color3.fromRGB(200, 100, 255) },
				{ text = "to keep...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "And a weeping king...", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Is only entertaining for the ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "first act.", color = Color3.fromRGB(200, 100, 255) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "You’re dragging the ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "pacing ", color = Color3.fromRGB(200, 100, 255), shake = true },
				{ text = "down.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		-- [[ ALACT SNAPS: THE MUSIC DIES HERE ]]
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				-- Instantly cut the music to dead silence for dramatic effect
				{ text = "My wife just ", color = Color3.fromRGB(255, 50, 50), shake = true, SilenceMusic = true, Pause = 0.5 },
				{ text = "suffocated to death...", color = Color3.fromRGB(170, 0, 0), shake = true, TypeSpeed = 0.08 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "On your ", color = Color3.fromRGB(255, 50, 50), shake = true },
				-- Add a heavy hit/shatter sound effect when he screams "script!"
				{ text = "script!", color = Color3.fromRGB(200, 100, 255), shake = true, SFX = 138122923 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Just let me fade out...", color = Color3.fromRGB(200, 200, 200), TypeSpeed = 0.06 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Let me go back to the ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "void...", color = Color3.fromRGB(100, 100, 100), shake = true }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Where I belong.", color = Color3.fromRGB(200, 200, 200), Pause = 1.5 }
			}
		},

		-- [[ ALICE DROPS THE ACT: NEW DARK THEME FADES IN ]]
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				-- Start playing a creepy, dark atmospheric track here (Replace 1842827150 if you want a different one)
				{ text = "You are being so terribly ", color = Color3.fromRGB(200, 200, 200), NewMusic = 107897722075748 },
				{ text = "uncreative ", color = Color3.fromRGB(200, 100, 255) },
				{ text = "today.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "This is your Dreamscape, Alact.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "You control the ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "ink ", color = Color3.fromRGB(100, 100, 100) },
				{ text = "here.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "If you miss her so much...", color = Color3.fromRGB(200, 200, 200), Pause = 0.5 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Just ", color = Color3.fromRGB(200, 200, 200), Pause = 0.5 },
				{ text = "draw a new one.", color = Color3.fromRGB(200, 100, 255), SFX = 91974224707874, Pause = 0.5}
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "In fact, make her smile more this time.", color = Color3.fromRGB(200, 200, 200) }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "The ", color = Color3.fromRGB(200, 200, 200) },
				{ text = "audience ", color = Color3.fromRGB(200, 100, 255), shake = true }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Really didn't like how much the last one complained.", color = Color3.fromRGB(200, 200, 200) }
			}
		},

		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "It wouldn't be her!", color = Color3.fromRGB(255, 50, 50), shake = true, Pause = 0.5 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "It would just be an ", color = Color3.fromRGB(200, 200, 200), shake = true, Pause = 0.5 },
				{ text = "empty husk...", color = Color3.fromRGB(100, 100, 100), shake = true, Pause = 0.5 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Wearing her face!", color = Color3.fromRGB(200, 200, 200), shake = true, Pause = 0.5 }
			}
		},
		{
			Speaker = "Alact",
			SpeakerColor = Color3.fromRGB(150, 150, 150),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "I can't love a ", color = Color3.fromRGB(255, 50, 50), shake = true, Pause = 0.5 },
				{ text = "puppet!", color = Color3.fromRGB(200, 100, 255), shake = true, Pause = 0.5 }
			}
		},

		-- [[ THE FINAL THREAT: OMINOUS & SLOW ]]
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Love? ", color = Color3.fromRGB(255, 100, 100), Pause = 0.75 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Who said anything about love?", color = Color3.fromRGB(200, 200, 200), Pause = 0.75 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "I said the ", color = Color3.fromRGB(200, 200, 200), Pause = 0.75 },
				{ text = "story ", color = Color3.fromRGB(200, 100, 255), Pause = 0.75 },
				{ text = "needs a Queen.", color = Color3.fromRGB(200, 200, 200), Pause = 0.75 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "Real human actors ", color = Color3.fromRGB(150, 150, 150), Pause = 0.75 },
				{ text = "are boring, my dear.", color = Color3.fromRGB(200, 200, 200), Pause = 0.75 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
				{ text = "A Fake ", color = Color3.fromRGB(200, 100, 255), shake = true, Pause = 0.75 },
				{ text = "is so much better...", color = Color3.fromRGB(200, 200, 200), Pause = 0.75 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
			
				{ text = "If you fail to get your act together...", color = Color3.fromRGB(200, 200, 200), SilenceMusic = true, TypeSpeed = 0.08, Pause = 1.5 }
			}
		},
		{
			Speaker = "Alice",
			SpeakerColor = Color3.fromRGB(200, 100, 255),
			Image = "rbxassetid://127140220789393",
			Segments = {
			
				{ text = "Then I just might have to recast you.", color = Color3.fromRGB(170, 0, 0), shake = true, TypeSpeed = 0.12, SFX = 91974224707874 }	
			}
		}
	}

} 

return InteractionData