"""Authored regional vignettes for the Covenant, generated with CodeRabbit assistance."""
import json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
LANDS=[[
('Mournwatch','village','Funeral lamps still burn in homes whose owners have been erased. Bellmaker Oren keeps one lit for his brother.','Return the brother’s name','Use the lamp to track the Regent'),
('The Cinder Cathedral','temple','A choir of ash sings an unfinished burial rite. Cantor Sera fears the last verse will erase her own name.','Sing the final verse with Sera','Bind the choir to defend the road'),
('Hollowmere','water','An undertaker ferries empty coffins across a red lake. Each coffin carries an unpaid promise.','Pay the ferry toll for the forgotten','Claim the promises as debts'),
('Blackbell Citadel','fortress','Captain Rook guards a gate against soldiers who have forgotten which side they died for.','Open the gate to the nameless','Raise the old military standard'),
('Embergrave','volcano','Fire breaks through the burial fields. A smith has discovered the heat is fed by sealed soul vessels.','Break the vessels and cool the field','Temper your ore in the soul furnace'),
('The Unnamed City','city','The city’s street signs are blank. Cartographer Eda draws the routes from memories she is slowly losing.','Share the names you remember','Keep the only complete map'),
('Redwater Crypts','crypt','A flooded archive contains the first mortality tax. Its ink still stains the hands of anyone who reads it.','Publish the record','Hold it as leverage over the council'),
("Widow's Reach",'forest','Nessa plants a tree for each returning soldier. The oldest tree whispers with her husband’s voice.','Let Nessa hear the voice','Sever the binding for its aether'),
('The Broken Muster','battlefield','A drummer repeats the signal to retreat, a century too late. Undead companies march toward the sound.','Sound the dismissal','Redirect the companies to the fortress'),
('Caves of the Ninth Bell','cave','Miners uncovered a bell beneath the bedrock. Its ringing wakes sleepers in distant Lethiel.','Muffle the bell with burial cloth','Study its link to the gardens'),
('The Ossuary Exchange','market','An illicit broker sells remembered birthdays. A child has come to buy back her mother’s age.','Return the stolen birthdays','Confiscate the broker’s reserves'),
('Sanctuary of Last Breath','sanctuary','A necromancer keeps the mortally wounded alive by lending them his remaining years.','Organize voluntary donors','Bind the sanctuary to your command'),
('The Ashen Crown','arena','The Regent’s first champion offers a trial to anyone who will name the people buried beneath his throne.','Dedicate the trial to the erased','Claim the champion’s mantle'),
('Ravenfall Pass','mountain','Refugees cannot cross until the watch beacons burn. The fuel is stored in an abandoned execution tower.','Light the refugees’ road','Keep the beacon for your army'),
('Vesper Below','underground','A community beneath the capital preserves names in songs. Their keeper asks whether the surface is safe.','Teach their songs to travelers','Keep the refuge secret')], [
('Moonfall Gardens','garden','The flowers open only when someone remembers a childhood. Gardener Lune is running out of her own.','Plant ordinary seeds beside the magic','Preserve the memory-fed flowers'),
('The Skyroot Temple','temple','The temple hangs from roots that drink stolen years. A novice has found a way to lower it safely.','Help the novice lower the temple','Keep the temple beyond mortal reach'),
('Glasswater','water','Fish swim through reflections of another sky. Fisher Tavi found her father’s face in the catch.','Release the borrowed reflection','Keep it to study the Covenant'),
('Starbough Haven','village','Children without dreams sleep under a luminous tree. Its keeper offers them dreams taken from Vesper.','Help them make their own stories','Accept the borrowed dreams'),
('The Silver Cascade','waterfall','The waterfall flows upward at moonrise. Engineer Nym suspects a buried engine is turning the valley’s seasons.','Restore the river’s direction','Harness the reversed current'),
('Dreamless Refuge','sanctuary','Thalen’s apprentices shelter children beneath the roots. Their stores cannot survive another winter.','Share supplies with the refuge','Trade supplies for their allegiance'),
('Everspring Ruins','ruins','An abandoned elven city celebrates a festival with no living guests. Its lamps repeat the same spring forever.','End the endless festival','Keep a lamp burning for the lost'),
('Celestial Reach','sky','Astronomer Vey tracks islands against stars that never move. The sky itself may be an old illusion.','Share the true star chart','Seal the dangerous discovery'),
('The Luminous Heart','forest','A giant tree grows around a Vesper gravestone. Its oldest leaves remember the first treaty.','Read the treaty aloud','Take a leaf for private study'),
('Prismspine Mountains','mountain','Crystal outcrops hum when an oath is broken. Pilgrims have left hundreds of apologies in the scree.','Carry the apologies home','Use the crystals to judge strangers'),
('Orchid Sea','flowers','A field of orchids follows travelers like a tide. Botanist Fenn believes each bloom seeks its original owner.','Guide the flowers back to Vesper','Cultivate a guardian flower field'),
('The Sunken Conservatory','underground','Blind gardeners raise roots by listening to water. A merchant offers them sight in return for their garden.','Protect their independent sanctuary','Broker the merchant’s bargain'),
('Grotto of Quiet Stars','cave','Glowing moths spell names across a cave ceiling. The youngest explorer recognizes her own future epitaph.','Let her choose a different path','Preserve the prophecy as law'),
('The Wild Court','wildlife','Antlered spirits gather where hunters once paid tribute. Their speaker asks for an end to iron traps.','Remove the court’s traps','Demand safe passage in exchange'),
('The Dawn Observatory','arena','A guardian tests whether visitors value beauty more than life. Its mirrors show the cost of every garden.','Face the trial without the bargain','Claim the mirrors’ authority')], [
('Coppergate','city','Workers queue at gates built from their grandparents’ wages. Registrar Mira has found the original employment contracts.','Return the contracts to the workers','Renegotiate them under your seal'),
('The Golden Harbor','port','Dockmaster Pell tracks ships that arrive without crews. Their cargo was paid for in years rather than coin.','Release the cargo to bereaved families','Finance a new trading fleet'),
('Ironwake','industrial','Ves’s apprentices power a forge with honest coal. The council undercuts them with stolen aether.','Support the independent forge','Take a controlling stake'),
("The Merchant's Crown",'market','A market judge weighs promises against silver. A widow’s promise is the heaviest thing on the scales.','Honor the widow’s claim','Purchase the disputed debt'),
('Aureate Palace','palace','The palace guards polish an empty throne. The council hid the true succession in a locked public archive.','Open the succession record','Reserve it for your claim'),
('Freeguild Market','market','Three guilds share a warehouse but disagree over its keys. A flood will reach the grain before their vote ends.','Open the warehouse for relief','Demand a guild charter first'),
('The Clockwork Vault','vault','A machine calculates interest on stolen childhoods. Its caretaker cannot find a number large enough for the debt.','Cancel the impossible accounts','Transfer the accounts to your treasury'),
('The Last Mint','industrial','The mint’s final die bears no king. A young engraver asks whose face belongs on the new currency.','Choose a symbol of the three peoples','Choose the Wayfarer’s crest'),
('Library of Open Ledgers','library','Archivist Jun arranges forbidden ledgers by the names of victims. Soldiers have come for the index.','Protect the public index','Take custody of the ledgers'),
('The Hall of Petitions','palace','Petitioners sleep beneath murals of prosperity. Clerk Daro has read every plea and remembers every refusal.','Give the clerk authority to grant relief','Make relief dependent on loyalty'),
('The Amber Granaries','farm','Farmers grow food beside fields reserved for a royal parade. Their children have never seen the palace.','Return the parade fields to farming','Tax the fields to fund defenses'),
('Bridge of Nine Charters','bridge','Nine guilds charge a separate toll on one bridge. A caravan carries medicine that will spoil by nightfall.','Suspend the tolls for medicine','Buy exclusive crossing rights'),
('Estate of Borrowed Summers','estate','A noble’s orchard ripens all year while a neighboring village freezes. The roots reach the Golden Engine.','Cut the orchard’s hidden feed','Redistribute a share of its harvest'),
('The Concord Bastion','fortress','Soldiers from all three lands train together, but their banners tell three different accounts of the same battle.','Commission a shared history','Keep the banners under one command'),
('Arena of the Uncrowned','arena','A champion offers the council’s prize to anyone who can defeat him without accepting a title.','Fight for the public purse','Fight for the champion’s office')]]
cells=[[-2,-2],[2,-2],[-3,1],[3,1],[-1,-4],[1,-4],[-4,-3],[4,-3],[-5,0],[5,0],[-3,-5],[3,-5],[-6,-4],[6,-4],[0,-6]]
grounds=[['Ground037','Ground048','Ground054','Ground068','Rock020','Rock030','Rock035','Gravel023','Ground080','Rock051','Gravel041','Ground104','Rock061','Ground105'],['Grass001','Grass004','Grass005','Ground085','Ground086','Ground097','Ground103','Moss002','Rock058','Rock060','Grass006','Grass007','Ground109','Ground110'],['Bricks059','Bricks066','Bricks084','Bricks094','PavingStones070','PavingStones128','WoodFloor051','WoodFloor043','Marble006','Marble012','PavingStones138','PavingStones142','WoodFloor064','Marble016']]
regions=[]
for land,rows in enumerate(LANDS):
 for i,(name,kind,lore,a,b) in enumerate(rows):
  regions.append(dict(id=f'{land}:{i}',land=land,index=i,name=name,kind=kind,cell=cells[i],surface=grounds[land][i%14],lore=lore,choices=[a,b],activity='trial' if kind in ['arena','battlefield','crypt','vault','cave'] else ('trade' if kind in ['market','port','farm','industrial'] else 'memorial'),reward=40+i*3))
(ROOT/'game/data/regions.json').write_text(json.dumps({'generated_by':'CodeRabbit','regions':regions},indent=2)+'\n')
