#Syndicate Wars Level Inspector by Moburma

#VERSION 0.1
#LAST MODIFIED: 28/11/2024

<#
.SYNOPSIS
   This script can read Syndicate Wars level files (LEV00xxx.DAT) and let users edit and save them back.

.DESCRIPTION    
    An editor for Syndicate Wars level files
    
.RELATED LINKS
    https://github.com/swfans/swars
    https://tcrf.net/Notes:Syndicate_Wars_(DOS)
    
#>


#set temporary variables until a level is loaded
$filename = "No File Loaded"



function convert16bitint($Byteone, $Bytetwo) {
   
$converbytes16 = [byte[]]($Byteone,$Bytetwo)
$converted16 =[bitconverter]::ToInt16($converbytes16,0)

return $converted16

}


function convert32bitint($Byteone, $Bytetwo, $Bytethree, $ByteFour) {
   
$converbytes32 = [byte[]]($Byteone,$Bytetwo,$Bytethree,$ByteFour)
$converted32 =[bitconverter]::ToInt32($converbytes32,0)

return $converted32

}

function ConvertTo-BooleanArray($byteArray) {

    # Convert the number to binary string
    $binaryString = [Convert]::ToString($byteArray, 2).PadLeft(32, '0')

    $boolArray = @()
    # Convert the binary string to a boolean array
    foreach ($bit in $binaryString.ToCharArray()) {
        if ($bit -eq '1') {
            $boolArray += $true
        } else {
            $boolArray += $false
        }
    }

    $reversedArray = @()
    for ($i = $boolArray.Length - 1; $i -ge 0; $i--) {
    $reversedArray += $boolArray[$i]
    }

    $boolArray = $reversedArray
    return $boolArray
    }

function ConvertBooleantoBytes($rownum){

    $row = $groupsrelationsTable.Rows[$rownum]
    $byteValues = @() # Initialize an array to hold the byte values

    for ($setIndex = 0; $setIndex -lt 4; $setIndex++) {
        $bitField = 0
        for ($bitIndex = 0; $bitIndex -lt 32; $bitIndex++) {
            # Calculate the column index based on the set index and reverse the bit order
            $columnIndex = ($setIndex * 32) + ($bitindex)#(31 - $bitIndex)
            if ($row[$columnIndex] -eq $true) {
                # Set the bit at the bitIndex position
                $bitField = $bitField -bor (1 -shl $bitIndex)
            }
            
        }
        # Convert the integer bitfield to a byte array
         $byteArray = [System.BitConverter]::GetBytes($bitField)
        
        # Add the byte array to the byteValues array
        $byteValues += $byteArray[0..3]
    }
        Return $byteValues
    
}

$zerobyte = [System.Convert]::ToString(0,16) -as [Byte] # Use this for zero byte entries going forward
function identifycharacter($chartype){ #Returns what the Character type is

    $switchDict = @{
        0 = "Invalid"
        1 = "Agent"
        2 = "Zealot"
        3 = "Unguided Female"
        4 = "Civ - Briefcase Man"
        5 = "Civ - White Dress Woman"
        6 = "Soldier/Mercenary"
        7 = "Mechanical Spider"
        8 = "Police"
        9 = "Unguided Male"
        10 = "Scientist"
        11 = "Shady Guy"
        12 = "Elite Zealot"
        13 = "Civ - Blonde Woman 1"
        14 = "Civ - Leather Jacket Man"
        15 = "Civ - Blonde Woman 2"
        40 = "Ground Car"
        50 = "Flying vehicle"
        51 = "Tank"
        54 = "Ship"
        59 = "Moon Mech"
    }
   
    $result = $switchDict[$chartype]
    if (-not $result) {
        Foreach ($Key in ($switchDict.GetEnumerator() | Where-Object {$_.Value -eq $chartype})){$result = $Key.name}
    }
    
        #$result = "Unknown"
    
    Return $result
    
}

function identifycommand($commandtype){ #Returns what the command name is
    $commandDict = @{
        0 = 'NONE'
        1 = 'STAY'
        2 = 'GO_TO_POINT'
        3 = 'GO_TO_PERSON'
        4 = 'KILL_PERSON'
        5 = 'KILL_MEM_GROUP'
        6 = 'KILL_ALL_GROUP'
        7 = 'PERSUADE_PERSON'
        8 = 'PERSUADE_MEM_GROUP'
        9 = 'PERSUADE_ALL_GROUP'
        10 = 'BLOCK_PERSON'
        11 = 'SCARE_PERSON'
        12 = 'FOLLOW_PERSON'
        13 = 'SUPPORT_PERSON'
        14 = 'PROTECT_PERSON'
        15 = 'HIDE'
        16 = 'GET_ITEM'
        17 = 'USE_WEAPON'
        18 = 'DROP_SPEC_ITEM'
        19 = 'AVOID_PERSON'
        20 = 'WAND_AVOID_GROUP'
        21 = 'DESTROY_BUILDING'
        22 = '16'
        23 = 'USE_VEHICLE'
        24 = 'EXIT_VEHICLE'
        25 = 'CATCH_TRAIN'
        26 = 'OPEN_DOME'
        27 = 'CLOSE_DOME'
        28 = 'DROP_WEAPON'
        29 = 'CATCH_FERRY'
        30 = 'EXIT_FERRY'
        31 = 'PING_EXIST'
        32 = 'GOTOPOINT_FACE'
        33 = 'SELF_DESTRUCT'
        34 = 'PROTECT_MEM_G'
        35 = 'RUN_TO_POINT'
        36 = 'KILL_EVERYONE'
        37 = 'GUARD_OFF'
        38 = 'EXECUTE_COMS'
        39 = '27'
        50 = '32'
        51 = 'WAIT_P_V_DEAD'
        52 = 'WAIT_MEM_G_DEAD'
        53 = 'WAIT_ALL_G_DEAD'
        54 = 'WAIT_P_V_I_NEAR'
        55 = 'WAIT_MEM_G_NEAR'
        56 = 'WAIT_ALL_G_NEAR'
        57 = 'WAIT_P_V_I_ARRIVES'
        58 = 'WAIT_MEM_G_ARRIVE'
        59 = 'WAIT_ALL_G_ARRIVE'
        60 = 'WAIT_P_PERSUADED'
        61 = 'WAIT_MEM_G_PERSUADED'
        62 = 'WAIT_ALL_G_PERSUADED'
        63 = 'WAIT_MISSION_SUCC'
        64 = 'WAIT_MISSION_FAIL'
        65 = 'WAIT_MISSION_START'
        66 = 'WAIT_OBJECT_DESTROYED'
        67 = 'WAIT_TIME'
        71 = 'WAND_P_V_DEAD'
        72 = 'WAND_MEM_G_DEAD'
        73 = 'WAND_ALL_G_DEAD'
        74 = 'WAND_P_V_I_NEAR'
        75 = 'WAND_MEM_G_NEAR'
        76 = 'WAND_ALL_G_NEAR'
        77 = 'WAND_P_V_I_ARRIVES'
        78 = 'WAND_MEM_G_ARRIVE'
        79 = 'WAND_ALL_G_ARRIVE'
        80 = 'WAND_P_PERSUADED'
        81 = 'WAND_MEM_G_PERSUADED'
        82 = 'WAND_ALL_G_PERSUADED'
        83 = 'WAND_MISSION_SUCC'
        84 = 'WAND_MISSION_FAIL'
        85 = 'WAND_MISSION_START'
        86 = 'WAND_OBJECT_DESTROYED'
        87 = 'WAND_TIME'
        110 = 'LOOP_COM'
        111 = 'UNTIL_P_V_DEAD'
        112 = 'UNTIL_MEM_G_DEAD'
        113 = 'UNTIL_ALL_G_DEAD'
        114 = 'UNTIL_P_V_I_NEAR'
        115 = 'UNTIL_MEM_G_NEAR'
        116 = 'UNTIL_ALL_G_NEAR'
        117 = 'UNTIL_P_V_I_ARRIVES'
        118 = 'UNTIL_MEM_G_ARRIVE'
        119 = 'UNTIL_ALL_G_ARRIVE'
        120 = 'UNTIL_P_PERSUADED'
        121 = 'UNTIL_MEM_G_PERSUADED'
        122 = 'UNTIL_ALL_G_PERSUADED'
        123 = 'UNTIL_MISSION_SUCC'
        124 = 'UNTIL_MISSION_FAIL'
        125 = 'UNTIL_MISSION_START'
        126 = 'UNTIL_OBJECT_DESTROYED'
        127 = 'UNTIL_TIME'
        128 = 'WAIT_OBJ'
        129 = 'WAND_OBJ'
        130 = 'UNTIL_OBJ'
        131 = 'WITHIN_AREA'
        132 = 'WITHIN_OFF'
        133 = 'LOCK_BUILD'
        134 = 'UNLOCK_BUILD'
        135 = 'SELECT_WEAPON'
        136 = 'HARD_AS_AGENT'
        137 = 'UNTIL_G_NOT_SEEN'
        138 = 'START_DANGER_MUSIC'
        139 = 'PING_P_V'
        140 = 'CAMERA_TRACK'
        141 = 'UNTRUCE_GROUP'
        142 = 'PLAY_SAMPLE'
        143 = 'IGNORE_ENEMIES'
        144 = 'FULL_STAMINA'
        145 = 'CAMERA_ROTATE'
    }

    $result = $commandDict[$commandtype]
    if (-not $result) {
        Foreach ($Key in ($commandDict.GetEnumerator() | Where-Object {$_.Value -eq $commandtype})){$result = $Key.name}
    }
        #$result = "Unknown"
    
    Return $result
}

function IdentifyItem($itemType) {

    $itemDict = @{
        0 = 'Briefcase'
        1 = 'Uzi'
        2 = 'Minigun'
        3 = 'Pulse Laser'
        4 = 'Electron Mace'
        5 = 'Launcher'
        6 = 'Nuclear Grenade'
        7 = 'Persuadertron'
        8 = 'Flamer'
        9 = 'Disrupter'
        10 = 'Psycho Gas'
        11 = 'Knockout Gas'
        12 = 'Ion Mine'
        13 = 'High Explosive'
        14 = 'Nothing'
        15 = 'LR Rifle'
        16 = 'Satellite Rain'
        17 = 'Plasma Lance'
        18 = 'Razor Wire'
        19 = 'Nothing'
        20 = 'Graviton Gun'
        21 = 'Persuadertron II'
        22 = 'Stasis Field'
        23 = 'Nothing'
        24 = 'Chromotap'
        25 = 'Displacertron'
        26 = 'Cerberus IFF'
        27 = 'Medikit'
        28 = 'Automedikit'
        29 = 'Trigger Wire'
        30 = 'Clone Shield'
        31 = 'Epidermis'
    }

    $result = $itemDict[$ItemType]
    if (-not $result) {
        $result = 'Unknown'
    }
    Return $result
}


function IdentifyEpidermis {
    param (
        [int]$Itemtype
    )

    $epidermisDict = @{
        1 = 'Epidermis 1 - Hard Skin'
        2 = 'Epidermis 2 - Flame Skin'
        3 = 'Epidermis 3 - Energy Skin'
        4 = 'Epidermis 4 - Stealth Skin'
    }

    $result = $epidermisDict[$Itemtype]
    if (-not $result) {
        $result = 'Unknown'
    }
    Return $result
}

function IdentifyVehicle($VehicleType) {

    $vehicleDict = @{
        0 = 'Civilian car (grey)'
        1 = 'DeLorean (grey)'
        2 = 'Bike'
        3 = 'Brown flyer'
        4 = 'Train engine'
        5 = 'Train carriage'
        6 = 'APC'
        7 = 'Large APC'
        8 = 'Police car'
        9 = 'Police Truck'
        10 = 'Small industrial vehicle'
        11 = 'Bullfrog Van'
        12 = 'Fire Engine'
        13 = 'Ambulance'
        14 = 'Taxi (Yellow)'
        15 = 'Barge'
        16 = 'Missile Frigate'
        17 = 'Luxury Yacht'
        18 = 'Tank'
        19 = 'Tank missile battery?'
        20 = 'Missile (small)'
        21 = 'Civilian car (Red)'
        22 = 'DeLorean (Yellow)'
        23 = 'Zealot Imperial Shuttle'
        24 = 'Taxi (Red)'
        25 = 'Missile (Large)'
        26 = 'Head of moon Mech'
        27 = 'Chest of mech?'
        28 = 'Bike (Metallic)'
        29 = 'Claw Mech (black)'
        30 = 'Claw Mech (Red)'
        31 = '2000AD/Manga Truck'
        32 = 'Moon Mech leg'
        33 = 'Moon Mech leg'
        34 = 'Moon Mech leg'
        35 = 'Moon Mech leg'
        36 = 'Moon Mech Arm'
        37 = 'Moon Mech Arm'
        38 = 'Moon Mech Gun'
        39 = 'Moon Mech Gun'
    }

    $result = $vehicleDict[$VehicleType]
    if (-not $result) {
        Foreach ($Key in ($vehicleDict.GetEnumerator() | Where-Object {$_.Value -eq $VehicleType})){$result = $Key.name}
    }
    
        #$result = "Unknown"
    
    Return $result
}

function IdentifyCity($cityNum) {

    $cityDict = @{
        '001' = 'Hong Kong'
        '002' = 'Matochkin Shar'
        '003' = 'Bangkok'
        '004' = 'New York'
        '005' = 'Sevastopol'
        '006' = 'Adelaide'
        '007' = 'Santiago'
        '008' = 'Nuuk'
        '009' = 'Singapore'
        '010' = 'Phoenix'
        '011' = 'Orbital Station'
        '012' = 'Orbital Station (Test)'
        '013' = 'Pre-Alpha Demo'
        '020' = 'Riyadh'
        '021' = 'Geneva'
        '022' = 'Johannesburg'
        '025' = 'Tripoli'
        '026' = 'Buenos Aires'
        '027' = 'New Delhi'
        '028' = 'Rome'
        '030' = 'London'
        '032' = 'Beijing'
        '035' = 'Detroit'
        '036' = 'Christ Church'
        '040' = 'Hawaii'
        '041' = 'Bahrain'
        '044' = 'Cape Town'
        '045' = 'Cairo'
        '046' = 'Colombo'
        '047' = 'Tokyo'
        '050' = 'Vancouver'
        '051' = 'Bullfrog logo'
        '052' = 'Anchorage - early'
        '060' = 'Anchorage'
        '065' = 'The Moon'
        '070' = 'Tokyo (Demo)'
        '074' = 'Unknown - single building'
        '079' = 'Reykjavik'
    }

    $result = $cityDict[$cityNum]
    if (-not $result) {
        $result = 'Unknown'
    }
    Return $result
}

function identifyGroup($groupNum){

    $matchingRow = $groupsTable.Select("GroupNo = '$groupNum'")
    if ($matchingRow.Length -gt 0) {
        $matchingValue = $matchingRow[0]["GroupName"]
        Return $matchingValue
    } else {
        Return ""
    }
}

function thingColour($thingColour){
    Switch ($thingColour){  

     2{ return 'Green'}
     3{ return 'Yellow'}
     5{ return 'Red'}
     7{ return 'Blue'}
     10{ return 'Cyan'}
     11{ return 'White'}
     12{ return 'Purple'}

    }


}

function weaponNumber ($weapname){ 
    Switch ($weapname) {
        'Uzi'{ return 1 }
        'Minigun'{ return 2 }
        'Pulse Laser'{ return 4 }
        'Electron Mace'{ return 8 }
        'Launcher'{ return 16 }
        'Nuclear Grenade'{ return 32 }
        'Persuadertron'{ return 64 }
        'Flamer'{ return 128 }
        'Disrupter'{ return 256 }
        'Psycho Gas'{ return 512 }
        'Knockout Gas'{ return 1024 }
        'Ion Mine'{ return 2048 }
        'High Explosive'{ return 4096 }
        'LR Rifle'{ return 16384 }
        'Satellite Rain'{ return 32768 }
        'Plasma Lance'{ return 65536 }
        'Razor Wire'{ return 131072 }
        'Nothing'{ return 262144 }
        'Graviton Gun'{ return 524288 }
        'Persuadertron II'{ return 1048576 }
        'Stasis Field'{ return 2097152 }
        'Chromotap'{ return 8388608 }
        'Displacertron'{ return 16777216 }
        'Cerberus IFF'{ return 33554432 }
        'Medikit'{ return 67108864 }
        'Automedikit'{ return 134217728 }
        'Trigger Wire'{ return 268435456 }
        'Clone Shield'{ return 536870912 }

    }
}

function weaponInventory($thingWeapons){
    $weaponstext = $null
    if ($thingWeapons -ge 1){    
       

         		if ($thingWeapons / 2147483648 -ge 1) {
                    $thingWeapons = $thingWeapons % 2147483648
					$Weaponstext = $Weaponstext+" Unknown 2, " 
				}
				
				if ($thingWeapons / 1073741824 -ge 1) {
					$thingWeapons = $thingWeapons % 1073741824
					$Weaponstext = $Weaponstext+" Unknown 1, " 
				}
				
				if ($thingWeapons / 536870912 -ge 1) {
					$thingWeapons = $thingWeapons % 536870912
					$Weaponstext = $Weaponstext+" Clone Shield, " 
				}
				
				if ($thingWeapons / 268435456 -ge 1) {
					$thingWeapons = $thingWeapons % 268435456
					$Weaponstext = $Weaponstext+" Trigger Wire, " 
				}
				
				if ($thingWeapons / 134217728 -ge 1) {
					$thingWeapons = $thingWeapons % 134217728
					$Weaponstext = $Weaponstext+" Automedikit, " 
				}
				
				if ($thingWeapons / 67108864 -ge 1) {
					$thingWeapons = $thingWeapons % 67108864
					$Weaponstext = $Weaponstext+" Medikit, " 
				}
				
				if ($thingWeapons / 33554432 -ge 1) {
					$thingWeapons = $thingWeapons % 33554432
					$Weaponstext = $Weaponstext+" Cerberus IFF, " 
				}
				
				if ($thingWeapons / 16777216 -ge 1) {
					$thingWeapons = $thingWeapons % 16777216
					$Weaponstext = $Weaponstext+" Displacertron, " 
				}
				
				if ($thingWeapons / 8388608 -ge 1) {
					$thingWeapons = $thingWeapons % 8388608
					$Weaponstext = $Weaponstext+" Chromotap, " 
				}
				
				if ($thingWeapons / 2097152 -ge 1) {
					$thingWeapons = $thingWeapons % 2097152
					$Weaponstext = $Weaponstext+" Stasis Field, " 
				}
				
				if ($thingWeapons / 1048576 -ge 1) {
					$thingWeapons = $thingWeapons % 1048576
					$Weaponstext = $Weaponstext+" Persuadertron II, " 
				}
				
				if ($thingWeapons / 524288 -ge 1) {
					$thingWeapons = $thingWeapons % 524288
					$Weaponstext = $Weaponstext+" Graviton Gun, " 
				}
				
				if ($thingWeapons / 262144 -ge 1) {
					$thingWeapons = $thingWeapons % 262144
					$Weaponstext = $Weaponstext+" Sonic Blast, " 
				}
				
				if ($thingWeapons / 131072 -ge 1) {
					$thingWeapons = $thingWeapons % 131072
					$Weaponstext = $Weaponstext+" Razor Wire, " 
				}
				
				if ($thingWeapons / 65536 -ge 1) {
					$thingWeapons = $thingWeapons % 65536
					$Weaponstext = $Weaponstext+" Plasma Lance, " 
				}
				
				if ($thingWeapons / 32768 -ge 1) {
					$thingWeapons = $thingWeapons % 32768
					$Weaponstext = $Weaponstext+" Satellite Rain, " 
				}
				
				if ($thingWeapons / 16384 -ge 1) {
					$thingWeapons = $thingWeapons % 16384
					$Weaponstext = $Weaponstext+" LR Rifle, " 
				}
				
				if ($thingWeapons / 8192 -ge 1) {
					$thingWeapons = $thingWeapons % 8192
					$Weaponstext = $Weaponstext+" Napalm Mine, " 
				}
				
				if ($thingWeapons / 4096 -ge 1) {
					$thingWeapons = $thingWeapons % 4096
					$Weaponstext = $Weaponstext+" Explosives, " 
				}
				
				if ($thingWeapons / 2048 -ge 1) {
					$thingWeapons = $thingWeapons % 2048
					$Weaponstext = $Weaponstext+" Ion Mine, " 
				}
				
				if ($thingWeapons / 1024 -ge 1) {
					$thingWeapons = $thingWeapons % 1024
					$Weaponstext = $Weaponstext+" Knockout Gas, " 
				}
				
				if ($thingWeapons / 512 -ge 1) {
					$thingWeapons = $thingWeapons % 512
					$Weaponstext = $Weaponstext+" Psycho Gas, " 
				}
				
				if ($thingWeapons / 256 -ge 1) {
					$thingWeapons = $thingWeapons % 256
					$Weaponstext = $Weaponstext+" Disrupter, " 
				}
				
				if ($thingWeapons / 128 -ge 1) {
					$thingWeapons = $thingWeapons % 128
					$Weaponstext = $Weaponstext+" Flamer, " 
				}
				
				if ($thingWeapons / 64 -ge 1) {
					$thingWeapons = $thingWeapons % 64
					$Weaponstext = $Weaponstext+" Persuadertron, " 
				}
				
				if ($thingWeapons / 32 -ge 1) {
					$thingWeapons = $thingWeapons % 32
					$Weaponstext = $Weaponstext+" Nuclear Grenade, " 
				}	
				
				if ($thingWeapons / 16 -ge 1) {
					$thingWeapons = $thingWeapons % 16
					$Weaponstext = $Weaponstext+" Launcher, " 
				}
				
				if ($thingWeapons / 8 -ge 1) {
					$thingWeapons = $thingWeapons % 8
					$Weaponstext = $Weaponstext+" Electron Mace, " 
				}
				
				if ($thingWeapons / 4 -ge 1) {
					$thingWeapons = $thingWeapons % 4
					$Weaponstext = $Weaponstext+" Pulse Laser, " 
				}
				
				if ($thingWeapons / 2 -ge 1) {
					$thingWeapons = $thingWeapons % 2
					$Weaponstext = $Weaponstext+" Minigun, " 
				}
				
				if ($thingWeapons / 1 -ge 1) {
					$thingWeapons = $thingWeapons % 1
					$Weaponstext = $Weaponstext+" Uzi, " 
				}		

    }
    Else{
        $weaponstext ="Unarmed"
        }

        Return $weaponstext

}


function modNumber ($modname){ 
    Switch ($modname) {
        'Legs 1'{ return 1 }
        'Legs 2'{ return 2 }
        'Legs 3'{ return 4 }
        'Arms 1'{ return 8 }
        'Arms 2'{ return 16 }
        'Arms 3'{ return 32 }
        'Body 1'{ return 64 }
        'Body 2'{ return 128 }
        'Body 3'{ return 256 }
        'Brain 1'{ return 512 }
        'Brain 2'{ return 1024 }
        'Brain 3'{ return 2048 }
        'Epidermis 1'{ return 4096 }
        'Epidermis 2'{ return 8192 }
        'Epidermis 3'{ return 16384 }
        'Epidermis 4'{ return 32768 }
    }
}
function ModInventory($thingMods){
    $modstext = $null
    if ($thingMods -ge 1){    
       
         		if ($thingMods / 32768 -ge 1 -and $e -ne 1) {
                    $thingMods = $thingMods % 32768
					$modstext = $modstext+" Epidermis 4, " 
                    $e = 1
				}
				
				if ($thingMods / 16384 -ge 1 -and $e -ne 1) {
                    $thingMods = $thingMods % 16384
					$modstext = $modstext+" Epidermis 3, " 
                    $e = 1
				}
                if ($thingMods / 8192 -ge 1 -and $e -ne 1) {
                    $thingMods = $thingMods % 8192
					$modstext = $modstext+" Epidermis 2, " 
                    $e = 1
				}
                if ($thingMods / 4096 -ge 1 -and $e -ne 1) {
                    $thingMods = $thingMods % 4096
					$modstext = $modstext+" Epidermis 1, " 
                    $e = 1
				}
                if ($thingMods / 2048 -ge 1 -and $br -ne 1) {
                    $thingMods = $thingMods % 2048
					$modstext = $modstext+" Brain 3, " 
                    $br = 1
				}
                if ($thingMods / 1024 -ge 1 -and $br -ne 1) {
                    $thingMods = $thingMods % 1024
					$modstext = $modstext+" Brain 2, " 
                    $br = 1
				}
                if ($thingMods / 512 -ge 1 -and $br -ne 1) {
                    $thingMods = $thingMods % 512
					$modstext = $modstext+" Brain 1, " 
                    $br = 1
				}
                if ($thingMods / 256 -ge 1 -and $bo -ne 1) {
                    $thingMods = $thingMods % 256
					$modstext = $modstext+" Body 3, " 
                    $bo = 1
				}
                if ($thingMods / 128 -ge 1 -and $bo -ne 1) {
                    $thingMods = $thingMods % 128
					$modstext = $modstext+" Body 2, " 
                    $bo = 1
				}
                if ($thingMods / 64 -ge 1 -and $bo -ne 1) {
                    $thingMods = $thingMods % 64
					$modstext = $modstext+" Body 1, " 
                    $bo = 1
				}
                if ($thingMods / 32 -ge 1 -and $a -ne 1) {
                    $thingMods = $thingMods % 32
					$modstext = $modstext+" Arms 3, " 
                    $a = 1
				}
                if ($thingMods / 16 -ge 1 -and $a -ne 1) {
                    $thingMods = $thingMods % 16
					$modstext = $modstext+" Arms 2, " 
                    $a = 1
				}
                if ($thingMods / 8 -ge 1 -and $a -ne 1) {
                    $thingMods = $thingMods % 8
					$modstext = $modstext+" Arms 1, " 
                    $a = 1
				}
                if ($thingMods / 4 -ge 1 -and $l -ne 1) {
                    $thingMods = $thingMods % 4
					$modstext = $modstext+" Legs 3, " 
                    $l = 1
				}
                if ($thingMods / 2 -ge 1 -and $l -ne 1) {
                    $thingMods = $thingMods % 2
					$modstext = $modstext+" Legs 2, " 
                    $l = 1
				}
                if ($thingMods / 1 -ge 1 -and $l -ne 1) {
                    $thingMods = $thingMods % 1
					$modstext = $modstext+" Legs 1, " 
                    $l = 1
				}
            }
            Else{
                $modstext ="No Mods"
                }
        
                Return $modstext
}


function SortParentChild{
    $dataTable | ForEach-Object {
        $_.linkparent = 0
        $_.linkchild = 0
    }
    
# Sort the datatable by ThingOffset
$sortedTable = $dataTable | Sort-Object ThingOffset

# Populate linkparent and linkchild fields
for ($i = 0; $i -lt $sortedTable.Count; $i++) {
    #write-host $i
    if ($i -eq 0) {
        # Set linkchild to one less than its own ThingOffset
        $sortedTable[$i].linkchild = $sortedTable[$i].ThingOffset - 1
        $sortedTable[$i].linkparent = $sortedTable[$i+1].ThingOffset
        continue
    }
    if ($i -lt $sortedTable.Count - 1) {
        $sortedTable[$i].linkchild = $sortedTable[$i-1].ThingOffset
        $sortedTable[$i].linkparent = $sortedTable[$i+1].ThingOffset
    }
    Else {
        $sortedTable[$i].linkchild = $sortedTable[$i-1].ThingOffset
        $sortedTable[$i].linkparent = 0
    }
}
}

function SortLinkSame{
# Initialize the LinkSame field to 0
$dataTable | ForEach-Object {
    $_.LinkSame = 0
}

# Group the datatable by ThingType
$groupedTable = $dataTable | Group-Object ThingType

# Populate LinkSame field for each group
foreach ($ThingType in $groupedTable) {
    # Sort each group by ThingOffset
    $sortedGroup = $ThingType.Group | Sort-Object ThingOffset

    for ($i = 0; $i -lt $sortedGroup.Count; $i++) {
        if ($i -lt $sortedGroup.Count - 1) {
            # Update LinkSame to point to the next entry's ThingOffset within the same group
            $sortedGroup[$i].LinkSame = $sortedGroup[$i+1].ThingOffset
        } else {
            # For the last entry in the group, set LinkSame to 0
            $sortedGroup[$i].LinkSame = 0
        }
    }
}

}
function SortLinkSameGroup{

    # Initialize the LinkSameGroup field to 0
$dataTable | ForEach-Object {
    $_.LinkSameGroup = 0
}

# Filter the datatable for entries with ThingType equal to 3
$nonvehicles = $dataTable | Where-Object { $_.ThingType -eq 3 }

# Group the filtered entries by Group
$groupednonvehicles = $nonvehicles | Group-Object Group

# Populate LinkSameGroup field for each group
foreach ($group in $groupednonvehicles) {
    # Sort each group by ThingOffset
    $sortedGroup = $group.Group | Sort-Object ThingOffset

    for ($i = 0; $i -lt $sortedGroup.Count; $i++) {
        if ($i -lt $sortedGroup.Count - 1) {
            # Update LinkSameGroup to point to the next entry's ThingOffset within the same group
            $sortedGroup[$i].LinkSameGroup = $sortedGroup[$i+1].ThingOffset
        } else {
            # For the last entry in the group, set LinkSameGroup to 0
            $sortedGroup[$i].LinkSameGroup = 0
        }
    }
}
}

function MarkUnusedRows(){
   #Check to see if a command/chain is unused and mark it as such
   $numRowsDataGridView = $datagridview.Rows.Count
$numRowsCommandGridView = $commandgridview.Rows.Count

# Create a hashset to keep track of referenced command numbers
$referencedCommands = @{}

# Add rows referenced by ComHead in $datagridview
for ($i = 0; $i -lt $numRowsDataGridView; $i++) {
    $comHeadValue = $datagridview.Rows[$i].Cells["ComHead"].Value
    if ($comHeadValue -ne 0) {
        $referencedCommands[$comHeadValue] = $true
        # Traverse the chain in $commandgridview
        $nextValue = $null
        for ($j = 0; $j -lt $numRowsCommandGridView; $j++) {
            if ($commandgridview.Rows[$j].Cells["commandno"].Value -eq $comHeadValue) {
                $nextValue = $commandgridview.Rows[$j].Cells["next"].Value
                break
            }
        }
        while ($nextValue -ne 0 -and $nextValue -ne $null) {
            $referencedCommands[$nextValue] = $true
            $currentValue = $nextValue
            $nextValue = $null
            for ($j = 0; $j -lt $numRowsCommandGridView; $j++) {
                if ($commandgridview.Rows[$j].Cells["commandno"].Value -eq $currentValue) {
                    $nextValue = $commandgridview.Rows[$j].Cells["next"].Value
                    break
                }
            }
        }
    }
}

# Find rows in $commandgridview that are not referenced and mark them grey
for ($j = 0; $j -lt $numRowsCommandGridView; $j++) {
    $commandNo = $commandgridview.Rows[$j].Cells["commandno"].Value
    if (-not $referencedCommands.ContainsKey($commandNo)) {
        $commandgridview.Rows[$j].DefaultCellStyle.BackColor = [System.Drawing.Color]::Gray
    }
}

# Refresh the $commandgridview to show the changes
$commandgridview.Refresh()
   
}

function AdvancedMode(){
    if ($datagridview.Columns[0].Visible -eq $false){
        $op = $true
    }
    Else{
        $op = $false
    }
    $datagridview.Columns[0].Visible = $op;
    $datagridview.Columns[1].Visible = $op;
    $datagridview.Columns[2].Visible = $op;
    $datagridview.Columns[3].Visible = $op;
    $datagridview.Columns[0].Visible = $op;
    $datagridview.Columns[9].Visible = $op;
    $datagridview.Columns[10].Visible = $op;
    $datagridview.Columns[11].Visible = $op;
    $datagridview.Columns[12].Visible = $op;
    $datagridview.Columns[22].Visible = $op;
    $datagridview.Columns[23].Visible = $op;
    $datagridview.Columns[24].Visible = $op;
    $datagridview.Columns[25].Visible = $op;
    $datagridview.Columns[32].Visible = $op;
    $datagridview.Columns[33].Visible = $op;
    $datagridview.Columns[34].Visible = $op;
    $datagridview.Columns[35].Visible = $op;
    $datagridview.Columns[36].Visible = $op;
    $datagridview.Columns[37].Visible = $op;
    $datagridview.Columns[38].Visible = $op;
    $datagridview.Columns[42].Visible = $op;
    $datagridview.Columns[43].Visible = $op;
    $datagridview.Columns[45].Visible = $op;
    $datagridview.Columns[46].Visible = $op;
    $datagridview.Columns[47].Visible = $op;
    $datagridview.Columns[48].Visible = $op;
    $datagridview.Columns[49].Visible = $op;
    $datagridview.Columns[52].Visible = $op;
    $datagridview.Columns[53].Visible = $op;
    $datagridview.Columns[54].Visible = $op;
    $datagridview.Columns[55].Visible = $op;
    $datagridview.Columns[56].Visible = $op;
    $datagridview.Columns[57].Visible = $op;
    $datagridview.Columns[58].Visible = $op;
    $datagridview.Columns[59].Visible = $op;
    $datagridview.Columns[61].Visible = $op;
    $datagridview.Columns[63].Visible = $op;
    $datagridview.Columns[64].Visible = $op;
    $datagridview.Columns[65].Visible = $op;
    $datagridview.Columns[66].Visible = $op;
    $datagridview.Columns[67].Visible = $op;
    $datagridview.Columns[68].Visible = $op;
    $datagridview.Columns[69].Visible = $op;
    $datagridview.Columns[70].Visible = $op;
    $datagridview.Columns[71].Visible = $op;
    $datagridview.Columns[73].Visible = $op;
    $datagridview.Columns[74].Visible = $op;
    $datagridview.Columns[75].Visible = $op;
    $datagridview.Columns[76].Visible = $op;
    $datagridview.Columns[77].Visible = $op;
    $datagridview.Columns[78].Visible = $op;
    $datagridview.Columns[79].Visible = $op;
    $datagridview.Columns[81].Visible = $op;
    $datagridview.Columns[84].Visible = $op;
    $datagridview.Columns[86].Visible = $op;
    $datagridview.Columns[87].Visible = $op;
    $datagridview.Columns[88].Visible = $op;

    $commandgridview.Columns[8].Visible = $op;
    $commandgridview.Columns[15].Visible = $op;

}
function SaveFile(){
   
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") 

    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.initialDirectory = $scriptdir 
    $OpenFileDialog.filter = "DAT files (*.DAT)| *.DAT"
    $OpenFileDialog.ShowDialog() |  Out-Null

    $outputfile = $OpenFileDialog.filename
    write-host $outputfile
    
    if ($outputfile -eq ""){ # User cancelled save file requester
        return 
    }

    Add-Type -AssemblyName System.Windows.Forms
    $recalc = [System.Windows.Forms.MessageBox]::Show('Do you want to recalc Parent/Child etc?', 'Confirmation', [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($recalc -eq 'Yes') {
        SortParentChild
        SortLinkSame
        SortLinkSameGroup
    }
    

    $zerobyte = [System.BitConverter]::GetBytes(0)

    try {
        $outputStream = [System.IO.File]::Create($outputfile)

    }
    catch {
        # If an error occurs, the catch block will run
        if ($_.Exception -is [System.IO.IOException] -and $_.Exception.Message -match "it is being used by another process") {
            [System.Windows.Forms.MessageBox]::Show('Error, cannot save, file is open elsewhere', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK)
            return
        }
        else {
            [System.Windows.Forms.MessageBox]::Show('An error occured saving the file', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK)
            return
        }
    }
    
    $outputStream.Write($levfile, 0, 4) #Take file version from input file

    #Get number of characters in level and write back

    $outputStream.Write([System.BitConverter]::GetBytes($datatable.Rows.count), 0, 2)
    $rowcounter = 0
  
    foreach ($drow in $Datatable)
    {   
        $rowcounter = $rowcounter + 1
        #write-host "writing Thing $rowcounter"
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Parent), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Next), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LinkParent), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LinkChild), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.type), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.thingtype), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.state), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Flag), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LinkSame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LinkSameGroup), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Radius), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ThingOffset), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.map_posx), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.map_posy), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.map_posz), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Frame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.StartFrame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Timer1), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.StartTimer1), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.VX), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.VY), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.VZ), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Speed), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Health), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Owner), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.PathOffset), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.SubState), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.PTarget), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Flag2), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.GotoThingIndex), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.OldTarget), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.PathIndex), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.UniqueID), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Group), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.EffectiveGroup), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ComHead), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ComCur), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.SpecialTimer), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Angle), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.WeaponTurn), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Brightness), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ComRange), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.BumpMode), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.BumpCount), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Vehicle), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LinkPassenger), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Within), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LastDist), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ComTimer), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Timer2), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.StartTimer2), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.AnimMode), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.OldAnimMode), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.OnFace), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.UMod), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Mood), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.FId0), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.FId1), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.FId2), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.FId3), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.FId4), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Shadows), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.RecoilTimer), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.MaxHealth), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Flag3), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.OldSubType), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ShieldEnergy), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.ShieldGlowTimer), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.WeaponDir), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.SpecialOwner), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.WorkPlace), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.LeisurePlace), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.WeaponTimer), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Target2), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.MaxShieldEnergy), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.PersuadePower), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.MaxEnergy), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Energy), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.RecoilDir), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.CurrentWeapon), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.GotoX), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.GotoZ), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.TempWeapon), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.Stamina), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.MaxStamina), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($drow.WeaponsCarried), 0, 4)

        if ($drow.thingtype -eq 2 ){ #if vehicle, write extra vehicle bytes
            #write-host "writing vehicle data"
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectWidth), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.Objectskewleft), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.Objectskewright), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectRoll), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectHeight), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectPitch), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectSkew2), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectStretch), 0, 4)
            $outputStream.Write([System.BitConverter]::GetBytes($drow.ObjectLength), 0, 4)
        }
            
    }

    #Command data start
    $outputStream.Write([System.BitConverter]::GetBytes($commandTable.Rows.count), 0, 2)
    
    foreach ($crow in $commandTable){
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Next), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.OtherThing), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.X), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Y), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Z), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Type), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.SubType), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Arg1), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Arg2), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Time), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.MyThing), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Parent), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Flags), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($crow.Field_1C), 0, 4)
    }

    $outputStream.Write($levfile, $gstart, 44)  #Copy existing level file groups header, not sure of significance of this, think it's actually not important
    
    [byte[]]$GNameOutput

    foreach ($grow in $groupsTable){
        
        $paddedBytes = [System.Text.Encoding]::ASCII.GetBytes($grow.groupname)
        $padLength = (40 - $paddedBytes.Length)
        $GNameOutput += $paddedBytes
        if ($padlength -gt 0){
        DO{
        $GNameOutput += $zerobyte[0]
        $padLength = $padLength - 1
        }UNTIL ($padlength -lt 1)
    }
    }

    $outputStream.Write($GNameOutput, 0, $GNameOutput.Length)

    $outputStream.Write($levfile, $gend, 40) # output group alliances, cheating for now
   
    [byte[]]$Groupoutput

    for ($i = 0; $i -lt 32; $i++) {
        $Groupoutput += ConvertBooleantoBytes($i)
        
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][0] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][1] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][2] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][3] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][4] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][5] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][6] )
        $Groupoutput += $paddedBytes[0]
        $PaddedBytes = [System.BitConverter]::GetBytes($guardiansTable.rows[$i][7] )
        $Groupoutput += $paddedBytes[0]
        $padLength = 16
        DO{
            $Groupoutput += $zerobyte[0]
            $padLength = $padLength - 1
        }UNTIL ($padlength -lt 1)
        }
    
        $outputStream.Write($Groupoutput, 0, $Groupoutput.Length)
        
    #Strange header/padding between groups and items

    [byte[]] $gheader = 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    $outputStream.Write($gheader, 0, $gheader.Length)

    #output items data
    $PaddedBytes = [System.BitConverter]::GetBytes($itemsTable.Rows.count) #number of items
    $outputStream.Write($paddedBytes, 0, 2)


    foreach ($irow in $itemsTable){
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemParent), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemNext), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemLinkParent), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemLinkChild), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemSubType), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemType), 0, 1)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemState), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemFlag), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemLinkSame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemObject), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemRadius), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemThingOffset), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemX), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemY), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemZ), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemFrame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemStartFrame), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemTimer1), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemStartTimer1), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemWeaponType), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemLastFired), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemAmmo), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemOwner), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemOnFace), 0, 2)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.Itemfield_38), 0, 4)
        $outputStream.Write([System.BitConverter]::GetBytes($irow.ItemUniqueid), 0, 2)
    }
    
    #unknown final bytes to end
    $remainingBytesLength = $levfile.count - $itemsend
    $outputStream.Write($levfile, $itemsend, $remainingBytesLength)
    $outputStream.Close()
    
    write-host "Done"
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $SaveButtonType = [System.Windows.MessageBoxButton]::Ok
    $SaveMessageboxTitle = "Save Level File"
    $SaveMessageboxbody = "Level Saved Successfully"
    $SaveMessageIcon = [System.Windows.MessageBoxImage]::Information 
    [void][System.Windows.MessageBox]::Show($SaveMessageboxbody,$SaveMessageboxTitle,$SaveButtonType,$Savemessageicon)  

}


function LoadLevel(){

    param (
        [int]$newMap
    )

    $drawmap = 1
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $global:bmp = New-Object System.Drawing.Bitmap(256, 256)
    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") 

    if ($newMap -eq 1 ){ #If new map was called, load the empty template
         $filename = "$scriptdir\Template.DAT"
    }

    Else { #Otherwise show file requester
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $scriptdir
    #$OpenFileDialog.filter = "DAT files (*.DAT)| *.DAT"
    $OpenFileDialog.ShowDialog() |  Out-Null

    $filename = $OpenFileDialog.filename
    }
    

    if ($filename -eq ""){ # User cancelled load file requester
        return 
    }

    $global:fileonly = [io.path]::GetFileName("$filename")
    $global:fileonly = $global:fileonly.Substring(0,$global:fileonly.Length-4)
    [string]$global:mapNum = $global:fileonly.substring(1,3)
    write-host $global:mapNum


    $global:cityName = identifycity($global:mapNum)

    $global:levfile = Get-Content $filename -Encoding Byte -ReadCount 0 #Load the actual file

    $thingCount = convert16bitint $levfile[4] $levfile[5]
    $counter = 0
    #Check File type
    $filetype = $levfile[0]
    if ($filetype -lt 15){
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $LevelErrorButtonType = [System.Windows.MessageBoxButton]::Ok
        $LevelErrorMessageboxTitle = "Error"
        $LevelErrorMessageboxbody = "Pre-Alpha Level formats are not yet supported"
        $LevelErrorMessageIcon = [System.Windows.MessageBoxImage]::Error
        [void][System.Windows.MessageBox]::Show($LevelErrorMessageboxbody,$LevelErrorMessageboxTitle,$LevelErrorButtonType,$LevelErrormessageicon)  
    
        Return
    }

    $Datatable.Rows.Clear();
    $commandTable.Rows.Clear();
    $groupsTable.Rows.Clear();
    $itemsTable.Rows.Clear();
    $groupsrelationsTable.Rows.Clear();
    $guardiansTable.Rows.Clear();

    $fpos = 6 # Move on to Thing data

    DO
    {

    $counter = $counter +1

    #Get Thing entries
    
    $Parent =  convert16bitint $levfile[$fpos] $levfile[$fpos+1]
    $Next =  convert16bitint $levfile[$fpos+2] $levfile[$fpos+3]
    $LinkParent = convert16bitint $levfile[$fpos+4] $levfile[$fpos+5]
    $LinkChild =  convert16bitint $levfile[$fpos+6] $levfile[$fpos+7]
    [int]$type = $levfile[$fpos+8]
    $charactername = identifycharacter $type
    $thingtype = $levfile[$fpos+9]
    $state = convert16bitint $levfile[$fpos+10] $levfile[$fpos+11]
    $Flag =  convert32bitint $levfile[$fpos+12] $levfile[$fpos+13] $levfile[$fpos+14] $levfile[$fpos+15]
    $LinkSame = convert16bitint $levfile[$fpos+16] $levfile[$fpos+17]
    $LinkSameGroup = convert16bitint $levfile[$fpos+18] $levfile[$fpos+19]
    $Radius = convert16bitint $levfile[$fpos+20] $levfile[$fpos+21]
    $ThingOffset = convert16bitint $levfile[$fpos+22] $levfile[$fpos+23]
    $map_posx = convert32bitint $levfile[$fpos+24] $levfile[$fpos+25] $levfile[$fpos+26] $levfile[$fpos+27]
    $map_posy = convert32bitint $levfile[$fpos+28] $levfile[$fpos+29] $levfile[$fpos+30] $levfile[$fpos+31]
    $map_posz = convert32bitint $levfile[$fpos+32] $levfile[$fpos+33] $levfile[$fpos+34] $levfile[$fpos+35]
    $Frame = convert16bitint $levfile[$fpos+36] $levfile[$fpos+37]
    [int]$StartFrame = convert16bitint $levfile[$fpos+38] $levfile[$fpos+39]
    $Timer1 = convert16bitint $levfile[$fpos+40] $levfile[$fpos+41]
    $StartTimer1 = convert16bitint $levfile[$fpos+42] $levfile[$fpos+43]
    $VX = convert32bitint $levfile[$fpos+44] $levfile[$fpos+45] $levfile[$fpos+46] $levfile[$fpos+47]
    $VY = convert32bitint $levfile[$fpos+48] $levfile[$fpos+49] $levfile[$fpos+50] $levfile[$fpos+51]
    $VZ = convert32bitint $levfile[$fpos+52] $levfile[$fpos+53] $levfile[$fpos+54] $levfile[$fpos+55]
    $Speed = convert16bitint $levfile[$fpos+56] $levfile[$fpos+57]
    $Health = convert16bitint $levfile[$fpos+58] $levfile[$fpos+59]
    $Owner = convert16bitint $levfile[$fpos+60] $levfile[$fpos+61]
    $PathOffset = $levfile[$fpos+62]
    $SubState = $levfile[$fpos+63]
    $PTarget = convert16bitint $levfile[$fpos+66] $levfile[$fpos+67]
    $Flag2 = convert32bitint $levfile[$fpos+68] $levfile[$fpos+69] $levfile[$fpos+70] $levfile[$fpos+71]
    $GotoThingIndex = convert16bitint $levfile[$fpos+72] $levfile[$fpos+73]
    $OldTarget = convert16bitint $levfile[$fpos+74] $levfile[$fpos+75]
    $PathIndex = convert16bitint $levfile[$fpos+76] $levfile[$fpos+77]
    $UniqueID = convert16bitint $levfile[$fpos+78] $levfile[$fpos+79]
    $Group = $levfile[$fpos+80]
    $GroupName = ""  #Update this later once we have the groupnames
    $EffectiveGroup = $levfile[$fpos+81]
    $ComHead = convert16bitint $levfile[$fpos+82] $levfile[$fpos+83]
    $ComCur = convert16bitint $levfile[$fpos+84] $levfile[$fpos+85]
    $SpecialTimer = $levfile[$fpos+86]
    $Angle = $levfile[$fpos+87]
    $WeaponTurn = convert16bitint $levfile[$fpos+88] $levfile[$fpos+89]
    $Brightness = $levfile[$fpos+90]
    $ComRange = $levfile[$fpos+91]
    $BumpMode = $levfile[$fpos+92]
    $BumpCount = $levfile[$fpos+93]
    $Vehicle =  convert16bitint $levfile[$fpos+94] $levfile[$fpos+95]
    $LinkPassenger = convert16bitint $levfile[$fpos+96] $levfile[$fpos+97]
    $Within = convert16bitint $levfile[$fpos+98] $levfile[$fpos+99]
    $LastDist = convert16bitint $levfile[$fpos+100] $levfile[$fpos+101]
    $ComTimer = convert16bitint $levfile[$fpos+102] $levfile[$fpos+103]
    $Timer2 = convert16bitint $levfile[$fpos+104] $levfile[$fpos+105]
    $StartTimer2 = convert16bitint $levfile[$fpos+106] $levfile[$fpos+107]
    $AnimMode = $levfile[$fpos+108]
    $OldAnimMode = $levfile[$fpos+109]
    $OnFace = convert16bitint $levfile[$fpos+110] $levfile[$fpos+111]
    $UMod = convert16bitint $levfile[$fpos+112] $levfile[$fpos+113]
    $Mood = convert16bitint $levfile[$fpos+114] $levfile[$fpos+115]
    $FId0 = $levfile[$fpos+116]
    $FId1 = $levfile[$fpos+117]
    $FId2 = $levfile[$fpos+118]
    $FId3 = $levfile[$fpos+119]
    $FId4 = $levfile[$fpos+120]
    $Shadows = convert32bitint $levfile[$fpos+121] $levfile[$fpos+122] $levfile[$fpos+123] $levfile[$fpos+124]
    $RecoilTimer = $levfile[$fpos+125]
    $MaxHealth = convert16bitint $levfile[$fpos+126] $levfile[$fpos+127]
    $Flag3 = $levfile[$fpos+128]
    $OldSubType = $levfile[$fpos+129]
    $ShieldEnergy = convert16bitint $levfile[$fpos+130] $levfile[$fpos+131]
    $ShieldGlowTimer = convert16bitint $levfile[$fpos+132] $levfile[$fpos+133]
    $WeaponDir = $levfile[$fpos+133]
    $SpecialOwner = convert16bitint $levfile[$fpos+134] $levfile[$fpos+135]
    $WorkPlace = convert16bitint $levfile[$fpos+136] $levfile[$fpos+137]
    $LeisurePlace = convert16bitint $levfile[$fpos+138] $levfile[$fpos+139]
    $WeaponTimer = convert16bitint $levfile[$fpos+140] $levfile[$fpos+141]
    $Target2 = convert16bitint $levfile[$fpos+142] $levfile[$fpos+143]
    $MaxShieldEnergy = convert16bitint $levfile[$fpos+144] $levfile[$fpos+145]
    $PersuadePower = convert16bitint $levfile[$fpos+146] $levfile[$fpos+147]
    $MaxEnergy = convert16bitint $levfile[$fpos+148] $levfile[$fpos+149]
    $Energy  = convert16bitint $levfile[$fpos+150] $levfile[$fpos+151]
    $RecoilDir = $levfile[$fpos+152]
    $CurrentWeapon = $levfile[$fpos+153]
    $GotoX = convert16bitint $levfile[$fpos+154] $levfile[$fpos+155]
    $GotoZ = convert16bitint $levfile[$fpos+156] $levfile[$fpos+157]
    $TempWeapon = convert16bitint $levfile[$fpos+158] $levfile[$fpos+159]
    $Stamina = convert16bitint $levfile[$fpos+160] $levfile[$fpos+161]
    $MaxStamina = convert16bitint $levfile[$fpos+162] $levfile[$fpos+163]
    $WeaponsCarried = convert32bitint $levfile[$fpos+164] $levfile[$fpos+165] $levfile[$fpos+166] $levfile[$fpos+167]
    $weaponsText = (weaponInventory $WeaponsCarried).trim()
    $modsText = (ModInventory $UMod).trim()

    if($Thingtype -eq 2 ){
        $vehicletype = identifyvehicle $startframe
        $Object = convert16bitint $levfile[$fpos+82] $levfile[$fpos+83]
        $MatrixIndex = convert16bitint $levfile[$fpos+84] $levfile[$fpos+85]
        $NumbObjects = $levfile[$fpos+86]
        $Dummy2 = $levfile[$fpos+87]
        $vWeaponTurn = convert16bitint $levfile[$fpos+88] $levfile[$fpos+89]
        $ReqdSpeed = convert16bitint $levfile[$fpos+90] $levfile[$fpos+91]
        $MaxSpeed = convert16bitint $levfile[$fpos+92] $levfile[$fpos+93]
        $PassengerHead = convert16bitint $levfile[$fpos+94] $levfile[$fpos+95]
        $TNode = convert16bitint $levfile[$fpos+96] $levfile[$fpos+97]
        $AngleDY = convert16bitint $levfile[$fpos+98] $levfile[$fpos+99]
        $AngleX = convert16bitint $levfile[$fpos+100] $levfile[$fpos+101]
        $AngleY = convert16bitint $levfile[$fpos+102] $levfile[$fpos+103]
        $AngleZ = convert16bitint $levfile[$fpos+104] $levfile[$fpos+105]
        $vGotoX = convert16bitint $levfile[$fpos+106] $levfile[$fpos+107]
        $vGotoY = convert16bitint $levfile[$fpos+108] $levfile[$fpos+109]
        $vGotoZ = convert16bitint $levfile[$fpos+110] $levfile[$fpos+111]
        $VehicleAcceleration = convert16bitint $levfile[$fpos+112] $levfile[$fpos+113]
        $vLeisurePlace = convert16bitint $levfile[$fpos+114] $levfile[$fpos+115]
        $TargetDX = convert16bitint $levfile[$fpos+116] $levfile[$fpos+117]
        $TargetDY = convert16bitint $levfile[$fpos+118] $levfile[$fpos+119]
        $TargetDZ = convert16bitint $levfile[$fpos+120] $levfile[$fpos+121]
        $vOnFace = convert16bitint $levfile[$fpos+122] $levfile[$fpos+123]
        $vWorkPlace = convert16bitint $levfile[$fpos+124] $levfile[$fpos+125]
        $vComHead = convert16bitint $levfile[$fpos+126] $levfile[$fpos+127]
        $vComCur = convert16bitint $levfile[$fpos+128] $levfile[$fpos+129]
        $vTimer2 = convert16bitint $levfile[$fpos+130] $levfile[$fpos+131]
        $vRecoilTimer = convert16bitint $levfile[$fpos+132] $levfile[$fpos+133]
        $vMaxHealth = convert16bitint $levfile[$fpos+134] $levfile[$fpos+135]
        $Dummy = convert16bitint $levfile[$fpos+136] $levfile[$fpos+137]
        $Dummy12 = convert16bitint $levfile[$fpos+138] $levfile[$fpos+139]
        $SubThing = convert16bitint $levfile[$fpos+148] $levfile[$fpos+149]
        $Agok = convert16bitint $levfile[$fpos+150] $levfile[$fpos+151]
        $WobbleZP = convert32bitint $levfile[$fpos+152] $levfile[$fpos+153] $levfile[$fpos+154] $levfile[$fpos+155]
        $WobbleZV = convert32bitint $levfile[$fpos+156] $levfile[$fpos+157] $levfile[$fpos+158] $levfile[$fpos+159]
        $Armour = $levfile[$fpos+160]
        $PissedOffWithWaiting = $levfile[$fpos+161]
        $ZebraOldHealth = convert16bitint $levfile[$fpos+162] $levfile[$fpos+163]
        $destx = convert16bitint $levfile[$fpos+164] $levfile[$fpos+165]
        $destz = convert16bitint $levfile[$fpos+166] $levfile[$fpos+167]
        
    
        $ObjectWidth = convert32bitint $levfile[$fpos+168] $levfile[$fpos+169] $levfile[$fpos+170] $levfile[$fpos+171]  #Default is normally 0400      
        $Objectskewleft = convert32bitint $levfile[$fpos+172] $levfile[$fpos+173] $levfile[$fpos+174] $levfile[$fpos+175] 
        $Objectskewright = convert32bitint $levfile[$fpos+176] $levfile[$fpos+177] $levfile[$fpos+178] $levfile[$fpos+179] 
        $ObjectRoll = convert32bitint $levfile[$fpos+180] $levfile[$fpos+181] $levfile[$fpos+182] $levfile[$fpos+183] 
        $ObjectHeight = convert32bitint $levfile[$fpos+184] $levfile[$fpos+185] $levfile[$fpos+186] $levfile[$fpos+187] #Default is normally 0400 
        $ObjectPitch = convert32bitint $levfile[$fpos+188] $levfile[$fpos+189] $levfile[$fpos+190] $levfile[$fpos+191]
        $ObjectSkew2 = convert32bitint $levfile[$fpos+192] $levfile[$fpos+193] $levfile[$fpos+194] $levfile[$fpos+195]
        $ObjectStretch = convert32bitint $levfile[$fpos+196] $levfile[$fpos+197] $levfile[$fpos+198] $levfile[$fpos+199]
        $ObjectLength = convert32bitint $levfile[$fpos+200] $levfile[$fpos+201] $levfile[$fpos+202] $levfile[$fpos+203] #Default is normally 0400 
    
    
        $fpos = $fpos +36
    }
    Else{
        $vehicletype = "N/A"
    }

    #plot map elements
    # note, the map is split into 128 cells comprised of 256 units per cell, so divide by 32768 to bodge into our 256 x 256 map

    if ( ($thingtype -eq 3 -and $type -eq 2) -or ($thingtype -eq 3 -and $type -eq 12)){ #Zealot map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'White')
    }
    Elseif ($thingtype -eq 3 -and $type -eq 1  ){ #Agent map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Red')
    }
    Elseif ($thingtype -eq 3 -and $type -eq 3 -or $type -eq 9  ){ #Unguided F+M map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Green')
    }
    Elseif ($thingtype -eq 3 -and $type -eq 6  ){ #Soldier map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Pink')
    }
    Elseif ($thingtype -eq 3 -and $type -eq 8  ){ #Police map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Purple')
    }
    Elseif ($thingtype -eq 3 -and $type -eq 10  ){ #Scientist map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Yellow')
    }
    Elseif ($thingtype -eq 2 ){ #vehicle map plot
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Turquoise')
    }
    
    Else{
        $bmp.SetPixel(($map_posx / 32768), ($map_posz / 32768), 'Gray')
    }

 
    #Define Thing datatable rows

    $row = $datatable.NewRow()  

    $row.Parent =  ($Parent)
    $row.Next =  ($Next)
    $row.LinkParent =  ($LinkParent)
    $row.LinkChild =  ($LinkChild)
    $row.Type =  ($type)
    $row.CharacternameHidden =  ($charactername)
    $row.ThingType =  ($thingtype)
    $row.VehicleTypeHidden = ($vehicleType)
    $row.State =  ($state)
    $row.Flag =  ($Flag)
    $row.LinkSame =  ($LinkSame)
    $row.LinkSameGroup =  ($LinkSameGroup)
    $row.Radius =  ($Radius)
    $row.ThingOffset =  ($ThingOffset)
    $row.map_posx =  ($map_posx)
    $row.map_posy =  ($map_posy)
    $row.map_posz =  ($map_posz)
    $row.Frame =  ($Frame)
    $row.StartFrame =  ($StartFrame)
    $row.Timer1 =  ($Timer1)
    $row.StartTimer1 =  ($StartTimer1)
    $row.VX =  ($VX)
    $row.VY =  ($VY)
    $row.VZ =  ($VZ)
    $row.Speed =  ($Speed)
    $row.Health =  ($Health)
    $row.Owner =  ($Owner)
    $row.PathOffset =  ($PathOffset)
    $row.SubState =  ($SubState)
    $row.PTarget =  ($PTarget)
    $row.Flag2 =  ($Flag2)
    $row.GotoThingIndex =  ($GotoThingIndex)
    $row.OldTarget =  ($OldTarget)
    $row.PathIndex =  ($PathIndex)
    $row.UniqueID =  ($UniqueID)
    $row.Group =  ($Group)
    $row.GroupName =  ($GroupName)
    $row.EffectiveGroup =  ($EffectiveGroup)
    $row.ComHead =  ($ComHead)
    $row.ComCur =  ($ComCur)
    $row.SpecialTimer =  ($SpecialTimer)
    $row.Angle =  ($Angle)
    $row.WeaponTurn =  ($WeaponTurn)
    $row.Brightness =  ($Brightness)
    $row.ComRange =  ($ComRange)
    $row.BumpMode =  ($BumpMode)
    $row.BumpCount =  ($BumpCount)
    $row.Vehicle =  ($Vehicle)
    $row.LinkPassenger =  ($LinkPassenger)
    $row.Within =  ($Within)
    $row.LastDist =  ($LastDist)
    $row.ComTimer =  ($ComTimer)
    $row.Timer2 =  ($Timer2)
    $row.StartTimer2 =  ($StartTimer2)
    $row.AnimMode =  ($AnimMode)
    $row.OldAnimMode =  ($OldAnimMode)
    $row.OnFace =  ($OnFace)
    $row.UMod =  ($UMod)
    $row.Mood =  ($Mood)
    $row.FId0 =  ($FId0)
    $row.FId1 =  ($FId1)
    $row.FId2 =  ($FId2)
    $row.FId3 =  ($FId3)
    $row.FId4 =  ($FId4)
    $row.Shadows =  ($Shadows)
    $row.RecoilTimer =  ($RecoilTimer)
    $row.MaxHealth =  ($MaxHealth)
    $row.Flag3 =  ($Flag3)
    $row.OldSubType =  ($OldSubType)
    $row.ShieldEnergy =  ($ShieldEnergy)
    $row.ShieldGlowTimer =  ($ShieldGlowTimer)
    $row.WeaponDir =  ($WeaponDir)
    $row.SpecialOwner =  ($SpecialOwner)
    $row.WorkPlace =  ($WorkPlace)
    $row.LeisurePlace =  ($LeisurePlace)
    $row.WeaponTimer =  ($WeaponTimer)
    $row.Target2 =  ($Target2)
    $row.MaxShieldEnergy =  ($MaxShieldEnergy)
    $row.PersuadePower =  ($PersuadePower)
    $row.MaxEnergy =  ($MaxEnergy)
    $row.Energy =  ($Energy)
    $row.RecoilDir =  ($RecoilDir)
    $row.CurrentWeapon =  ($CurrentWeapon)
    $row.GotoX =  ($GotoX)
    $row.GotoZ =  ($GotoZ)
    $row.TempWeapon =  ($TempWeapon)
    $row.Stamina =  ($Stamina)
    $row.MaxStamina =  ($MaxStamina)
    $row.WeaponsCarried =  ($weaponscarried)
    $row.WeaponsInventory =  ($weaponsText.TrimEnd(", "))
    $row.ModsInventory =  ($ModsText.TrimEnd(", "))
    if($flag2 -eq 16777216){ #Peeps with this flag are invisible on level start
        $row.Invisible = $true
    }
    if($flag2 -eq 536870912){ #Peeps with this flag are invisible on level start because they are inside a building
        $row.InsideBuilding = $true
    }
    if($Flag -eq 67108870){ #Peeps with this flag are dead on level start
        $row.Dead = $true
    }
    if($Thingtype -eq 2 ){
    $row.ObjectWidth = ($ObjectWidth)
    $row.Objectskewleft = ($Objectskewleft)
    $row.Objectskewright = ($Objectskewright)
    $row.ObjectRoll = ($ObjectRoll)
    $row.ObjectHeight = ($ObjectHeight)
    $row.ObjectPitch = ($ObjectPitch)
    $row.ObjectSkew2 = ($ObjectSkew2)
    $row.ObjectStretch = ($ObjectStretch)
    $row.ObjectLength = ($ObjectLength)
    }
    else {
        $row.ObjectWidth = ([System.DBNull]::Value)
        $row.Objectskewleft = ([System.DBNull]::Value)
        $row.Objectskewright = ([System.DBNull]::Value)
        $row.ObjectRoll = ([System.DBNull]::Value)
        $row.ObjectHeight = ([System.DBNull]::Value)
        $row.ObjectPitch = ([System.DBNull]::Value)
        $row.ObjectSkew2 = ([System.DBNull]::Value)
        $row.ObjectStretch = ([System.DBNull]::Value)
        $row.ObjectLength = ([System.DBNull]::Value)
    }


    $datatable.Rows.Add($row)

    $ThingCount = $ThingCount - 1


    $fpos = $fpos + 168
    }
    UNTIL ($ThingCount -eq 0)

    #load Commands data
    $commandcount = convert16bitint $levfile[$fpos] $levfile[$fpos+1] #Read command count header number
    write-host "$commandcount commands found"
    $fpos = $fpos+2

    $commnum = 0

    DO
    {
        
        $Next = convert16bitint $levfile[$fpos] $levfile[$fpos+1]
        $OtherThing = convert16bitint $levfile[$fpos+2] $levfile[$fpos+3]
        $X = convert16bitint $levfile[$fpos+4] $levfile[$fpos+5]
        $Y = convert16bitint $levfile[$fpos+6] $levfile[$fpos+7]
        $Z = convert16bitint $levfile[$fpos+8] $levfile[$fpos+9]
        [int]$Type = convert16bitint $levfile[$fpos+10] $levfile[$fpos+11]
        $CommandName = identifycommand $type
        $SubType = convert16bitint $levfile[$fpos+12] $levfile[$fpos+13]
        $Arg1 = convert16bitint $levfile[$fpos+14] $levfile[$fpos+15]
        $Arg2 = convert16bitint $levfile[$fpos+16] $levfile[$fpos+17]
        $Time = convert16bitint $levfile[$fpos+18] $levfile[$fpos+19]
        $MyThing = convert16bitint $levfile[$fpos+20] $levfile[$fpos+21]
        $Parent = convert32bitint $levfile[$fpos+22] $levfile[$fpos+23] 
        $Flags = convert32bitint $levfile[$fpos+24] $levfile[$fpos+25] $levfile[$fpos+26] $levfile[$fpos+27] 
        $Field_1C = convert32bitint $levfile[$fpos+28] $levfile[$fpos+29] $levfile[$fpos+30] $levfile[$fpos+31] 
      

        $row = $commandTable.NewRow()  
        $row.CommandNo =  ($commnum)
        $row.Next =  ($Next)
        $row.OtherThing =  ($OtherThing)
        $row.X =  ($X)
        $row.Y =  ($Y)
        $row.Z =  ($Z)
        $row.Type =  ($Type)
        $row.CommandNameHidden =  ($CommandName)
        $row.SubType =  ($SubType)
        $row.Arg1 =  ($Arg1)
        $row.Arg2 =  ($Arg2)
        $row.Time =  ($Time)
        $row.MyThing =  ($MyThing)
        $row.Parent =  ($Parent)
        $row.Flags =  ($Flags)
        $row.Field_1C =  ($Field_1C)
        $commandTable.Rows.Add($row)

        $fpos = $fpos+32
        $commnum = $commnum + 1

    $commandcount =  $commandcount -1

    }UNTIL ($commandcount  -eq 0)

    $Global:gstart = $fpos

    $fpos = $fpos+44

   

    #Groups Data

    $gcount = 0

    DO{
      
        $gname = [System.Text.Encoding]::UTF8.GetString($levfile[$fpos..($fpos+39)])
  
        $row = $groupstable.NewRow()  

        $row.groupno =  ($gcount)
        $row.groupName =  ($gname)

        $groupsTable.Rows.Add($row)

        $fpos = $fpos+40

    $gcount++
    }
    UNTIL ($gcount -eq 32)

 
    foreach ($drow in $dataTable.Rows){  #Loop to update Groupnames for all Things now we have group names
   
        $drow["GroupName"] = identifygroup ($drow["Group"])
    }

    $global:gend = $fpos


    $gcount = 0
    $fpos = $fpos + 40 #first group relations entry is a dummy
    DO{
    $KillOnSight = convert32bitint $levfile[$fpos] $levfile[$fpos+1] $levfile[$fpos+2] $levfile[$fpos+3]
    $KillIfWeaponOut = convert32bitint $levfile[$fpos+4] $levfile[$fpos+5] $levfile[$fpos+6] $levfile[$fpos+7]
    $KillIfArmed = convert32bitint $levfile[$fpos+8] $levfile[$fpos+9]  $levfile[$fpos+10] $levfile[$fpos+11]
    $Truce = convert32bitint $levfile[$fpos+12] $levfile[$fpos+13] $levfile[$fpos+14] $levfile[$fpos+15]
    if ($levfile[$fpos+16] -gt 31){  #Clamp group Guardian numbers between 0 and 31, some older levels seem to have nonsense values of 255 here
        $Guardians1 = 0
    }
    Else{
        $Guardians1 = $levfile[$fpos+16]
    }
    if ($levfile[$fpos+17] -gt 31){ 
        $Guardians2 = 0
    }
    Else{
        $Guardians2 = $levfile[$fpos+17]
    }
    if ($levfile[$fpos+18] -gt 31){ 
        $Guardians3 = 0
    }
    Else{
        $Guardians3 = $levfile[$fpos+18]
    }
    if ($levfile[$fpos+19] -gt 31){ 
        $Guardians4 = 0
    }
    Else{
        $Guardians4 = $levfile[$fpos+19]
    }
    if ($levfile[$fpos+20] -gt 31){ 
        $Guardians5 = 0
    }
    Else{
        $Guardians5 = $levfile[$fpos+20]
    }
    if ($levfile[$fpos+21] -gt 31){ 
        $Guardians6 = 0
    }
    Else{
        $Guardians6 = $levfile[$fpos+21]
    }
    if ($levfile[$fpos+22] -gt 31){ 
        $Guardians7 = 0
    }
    Else{
        $Guardians7 = $levfile[$fpos+22]
    }
    if ($levfile[$fpos+23] -gt 31){ 
        $Guardians8 = 0
    }
    Else{
        $Guardians8 = $levfile[$fpos+23]
    }

    
    $boolArray = ConvertTo-BooleanArray $KillOnSight 
    # Add a new row to the DataTable and populate it with the boolean values
    $row = $groupsrelationsTable.NewRow()
    for ($i = 0; $i -lt 32; $i++) {
    $row["KillOnSight$i"] = $boolArray[$i]
    #write-host "i is $i"
    #write-host  $boolArray[$i]
    }

    $boolArray = ConvertTo-BooleanArray $KillIfWeaponOut 
    # Add a new row to the DataTable and populate it with the boolean values

    for ($i = 0; $i -lt 32; $i++) {
    $row["KillIfWeaponOut$i"] = $boolArray[$i]
    }

    $boolArray = ConvertTo-BooleanArray $KillIfArmed 
    # Add a new row to the DataTable and populate it with the boolean values
  
    for ($i = 0; $i -lt 32; $i++) {
    $row["KillIfArmed$i"] = $boolArray[$i]
    }

    $boolArray = ConvertTo-BooleanArray $Truce 
    # Add a new row to the DataTable and populate it with the boolean values

    for ($i = 0; $i -lt 32; $i++) {
    $row["Truce$i"] = $boolArray[$i]
    }

    $groupsrelationsTable.Rows.Add($row)

    $row = $guardiansTable.NewRow()

    $row["Guardian0"] = $Guardians1
    $row["Guardian1"] = $Guardians2
    $row["Guardian2"] = $Guardians3
    $row["Guardian3"] = $Guardians4
    $row["Guardian4"] = $Guardians5
    $row["Guardian5"] = $Guardians6
    $row["Guardian6"] = $Guardians7
    $row["Guardian7"] = $Guardians8

    $guardiansTable.Rows.Add($row)

    $fpos = $fpos + 40
    $gcount++
    }
    UNTIL ($gcount -eq 32)

    #$fpos = $fpos + 1339
    $fpos = $fpos + 19

    $itemcount = convert16bitint $levfile[$fpos] $levfile[$fpos+1]
    write-host "item num $itemcount"
    $fpos = $fpos + 2

    if($itemcount -gt 0){
        DO
        {
        $itemcount = $itemcount -1
        $ItemParent = convert16bitint $levfile[$fpos] $levfile[$fpos+1]
        $ItemNext = convert16bitint $levfile[$fpos+2] $levfile[$fpos+3]
        $ItemLinkParent = convert16bitint $levfile[$fpos+4] $levfile[$fpos+5]
        $ItemLinkChild = convert16bitint $levfile[$fpos+6] $levfile[$fpos+7]
        $ItemSubType = $levfile[$fpos+8] 
        $ItemType  = $levfile[$fpos+9] 
        $ItemState  = convert16bitint $levfile[$fpos+10] $levfile[$fpos+11]
        $ItemFlag = convert32bitint $levfile[$fpos+12] $levfile[$fpos+13] $levfile[$fpos+14] $levfile[$fpos+15]
        $ItemLinkSame  = convert16bitint $levfile[$fpos+16] $levfile[$fpos+17]
        $ItemObject = convert16bitint $levfile[$fpos+18] $levfile[$fpos+19]
        $ItemRadius  = convert16bitint $levfile[$fpos+20] $levfile[$fpos+21]
        $ItemThingOffset = convert16bitint $levfile[$fpos+22] $levfile[$fpos+23]
        $ItemX = convert32bitint $levfile[$fpos+24] $levfile[$fpos+25] $levfile[$fpos+26] $levfile[$fpos+27]
        $ItemY = convert32bitint $levfile[$fpos+28] $levfile[$fpos+29] $levfile[$fpos+30] $levfile[$fpos+31]
        $ItemZ = convert32bitint $levfile[$fpos+32] $levfile[$fpos+33] $levfile[$fpos+34] $levfile[$fpos+35]
        $ItemFrame = convert16bitint $levfile[$fpos+36] $levfile[$fpos+37]
        $ItemStartFrame = convert16bitint $levfile[$fpos+38] $levfile[$fpos+39]
        $ItemTimer1 = convert16bitint $levfile[$fpos+40] $levfile[$fpos+41]
        $ItemStartTimer1 = convert16bitint $levfile[$fpos+42] $levfile[$fpos+43]
        [int]$ItemWeaponType = convert16bitint $levfile[$fpos+44] $levfile[$fpos+45]
        $ItemLastFired = convert16bitint $levfile[$fpos+46] $levfile[$fpos+47]
        $ItemAmmo = convert16bitint $levfile[$fpos+48] $levfile[$fpos+49]
        $ItemOwner = convert16bitint $levfile[$fpos+50] $levfile[$fpos+51]
        $ItemOnFace = convert16bitint $levfile[$fpos+52] $levfile[$fpos+53]
        $Itemfield_38 =  convert32bitint $levfile[$fpos+54] $levfile[$fpos+55] $levfile[$fpos+56] $levfile[$fpos+57]  
        $ItemUniqueid =  convert16bitint $levfile[$fpos+58] $levfile[$fpos+59] 

        if( $ItemWeaponType -eq "31"){
            $ItemName = identifyepidermis($ItemAmmo)
            }
        ElseIf ($ItemSubType -gt "0" -and $ItemType -eq "25" ){
        $itemname = "Money Briefcase ("+($ItemAmmo*100)+" credits)"
        }
        Else{
            
            $ItemName = identifyitem($ItemWeaponType)
        }

        $row = $itemsTable.NewRow()  
        $row.ItemParent = ($ItemParent)
        $row.ItemNext = ($ItemNext)
        $row.ItemLinkParent = ($ItemLinkParent)
        $row.ItemLinkChild = ($ItemLinkChild)
        $row.ItemSubType = ($ItemSubType)
        $row.ItemType = ($ItemType)
        $row.ItemName = ($ItemName)
        $row.ItemState = ($ItemState)
        $row.ItemFlag = ($ItemFlag)
        $row.ItemLinkSame = ($ItemLinkSame)
        $row.ItemObject = ($ItemObject)
        $row.ItemRadius = ($ItemRadius)
        $row.ItemThingOffset = ($ItemThingOffset)
        $row.ItemX = ($ItemX)
        $row.ItemY = ($ItemY)
        $row.ItemZ = ($ItemZ)
        $row.ItemFrame = ($ItemFrame)
        $row.ItemStartFrame = ($ItemStartFrame)
        $row.ItemTimer1 = ($ItemTimer1)
        $row.ItemStartTimer1 = ($ItemStartTimer1)
        $row.ItemWeaponType = ($ItemWeaponType)
        $row.ItemLastFired = ($ItemLastFired)
        $row.ItemAmmo = ($ItemAmmo)
        $row.ItemOwner = ($ItemOwner)
        $row.ItemOnFace = ($ItemOnFace)
        $row.Itemfield_38 = ($Itemfield_38)
        $row.ItemUniqueid = ($ItemUniqueid)
        $itemsTable.Rows.Add($row)


        $fpos = $fpos+60


        }
        UNTIL ($itemcount -eq 0)
    }

    $global:itemsend = $fpos

    if (test-path "$scriptdir/SWMaps/MAP$global:mapNum.png"){
    $mapimgfile = (get-item "$scriptdir/SWMaps/MAP$global:mapNum.png")
    }
    Else {
        $mapimgfile = (get-item "$scriptdir/SWMaps/MAP000.png")
    }

    

    $global:levimg = [System.Drawing.Image]::Fromfile($mapimgfile);
  
    $pictureBox.Image = $levimg
    $pictureBox.Size = New-Object System.Drawing.Size(256,256)
   

    #New attempt at drawing map
    $global:graphics=[System.Drawing.Graphics]::FromImage($levimg)
    $graphics.DrawImage($bmp,0,0,256,256)
    $picturebox.refresh()

    $Levelinfobox.text ="$filename 
City: $global:cityname
"
    $Thingcount = ($datagridview.Rowcount -1)
    $CommandCount = ($commandGridview.Rowcount -1)
    $ItemCount = ($itemsGridview.Rowcount -1)

    $ThingCountlabel.Text = "Things: $Thingcount 
Commands: $Commandcount 
Items: $ItemCount"

MarkUnusedRows

}


function NewLevel {

    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to start a new level? Existing progress will be lost.", "New Level confirmation", 'YesNo', 'Question')

    if ($result -eq 'Yes') {
        # Yes option was selected

        LoadLevel -newMap 1
    }
    else {
        # No option was selected
       Return
    }
}


function clearRow(){

    $currow = $datagridview.CurrentCell.RowIndex
    $dataGridView.Rows.RemoveAt($currow)

}

function CloneThingRow(){

    if ($dataGridView.SelectedCells.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a Thing to duplicate.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

   # Get the selected DataRowView
   $selectedRowView = $dataGridView.SelectedCells[0].OwningRow.DataBoundItem

   # Duplicate the DataRow
   $newRow = $dataTable.NewRow()
   $newRow.ItemArray = $selectedRowView.Row.ItemArray

   # Add the new DataRow to the DataTable
   $dataTable.Rows.Add($newRow)

   # Get the last row (which is the newly added row)
   $lastRowIndex = $dataTable.Rows.Count - 1
   $lastRow = $dataTable.Rows[$lastRowIndex]

   # Get the previous row (before the newly added row)
   $previousRow = $dataTable.Rows[$lastRowIndex - 1]

   # Update the UniqueID and ThingOffset in the new row
   if ($previousRow["Type"] -eq 51 -or $previousRow["Type"] -eq 59 ){   #if is a tank or mech vehicle previously, skip a number as it actually takes up TWO things
    $lastRow["UniqueID"] = [int]$previousRow["UniqueID"] + 2
    $lastRow["ThingOffset"] = [int]$previousRow["ThingOffset"] + 2
   }
   Else{
   $lastRow["UniqueID"] = [int]$previousRow["UniqueID"] + 1
   $lastRow["ThingOffset"] = [int]$previousRow["ThingOffset"] + 1
   }
   $dataTable.AcceptChanges()
}

function PasteThingCoords(){  #Paste current frozen mouse coordinates into Map X and Z for currently selected Thing to save typing
    if ($dataGridView.SelectedCells.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a Thing to paste coords to.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

   # Get the selected DataRowView
   $selectedRowView = $dataGridView.CurrentCell.RowIndex

    #write-host "row is $selectedRowView"

   $x = $global:lastMousePosition.X
   $y = $global:lastMousePosition.Y
   $datagridview.Rows[$selectedRowView].Cells[14].Value = ($x * 32768) #Update Map X coordinate from mouse X
   $datagridview.Rows[$selectedRowView].Cells[16].Value = ($y * 32768) #Update Map Z coordinate from mouse Y
}
function CloneCommandNewRow(){

    if ($CommandGridView.SelectedCells.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a Command to duplicate.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # Get the selected DataRowView
    $selectedRowView = $CommandGridView.SelectedCells[0].OwningRow.DataBoundItem

    # Duplicate the DataRow
    $newRow = $commandTable.NewRow()
    $newRow.ItemArray = $selectedRowView.Row.ItemArray

    # Add the new DataRow to the DataTable
    $commandTable.Rows.Add($newRow)

    $commandGridview.Rows[($commandGridview.Rows.count -2)].Cells[0].Value = ($commandGridview.Rows.count -2)

}

function CloneCommandRow(){

    if ($CommandGridView.SelectedCells.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select a Command to duplicate.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }
    write-host "cloning command"
    for ($i = 0; $i -lt 16; $i++) {

        if ($i -eq 0){ # Set command to be one more

            $CommandGridView.Rows[($CommandGridView.CurrentCell.RowIndex + 1)].Cells[0].Value = (($CommandGridView.Rows[($CommandGridView.CurrentCell.RowIndex)].Cells[0].Value) +1)
        }
        Else{
        $CommandGridView.Rows[($CommandGridView.CurrentCell.RowIndex + 1)].Cells[$i].Value = ($CommandGridView.Rows[($CommandGridView.CurrentCell.RowIndex)].Cells[$i].Value)
        }
    }

}

function StepCommandForward(){
   $comRowIndex = $commandGridview.CurrentCell.RowIndex
   $nextComm = $commandGridview.Rows[$comRowIndex].Cells['Next'].Value
   # Find the row in the Commands DataGridView with the related ID
   $relatedRowIndex = $commandGridview.Rows | Where-Object { $_.Cells['CommandNo'].Value -eq $nextComm } | ForEach-Object { $_.Index }

     # Select the corresponding row in the Commands DataGridView
     if ($relatedRowIndex -ne 0) {
        $commandGridview.CurrentCell = $commandGridview.Rows[$relatedRowIndex].Cells[0]
    }
      
}

function StepCommandBack(){
    $comRowIndex = $commandGridview.CurrentCell.RowIndex
    $nextComm = $commandGridview.Rows[$comRowIndex].Cells['CommandNo'].Value
    # Find the row in the Commands DataGridView with the related ID
    $relatedRowIndex = $commandGridview.Rows | Where-Object { $_.Cells['Next'].Value -eq $nextComm } | ForEach-Object { $_.Index }
 
      # Select the corresponding row in the Commands DataGridView
      if ($relatedRowIndex -ne 0) {
         $commandGridview.CurrentCell = $commandGridview.Rows[$relatedRowIndex].Cells[0]
     }
       
 }

#Datatable definitions

$Datatable = New-Object System.Data.DataTable

[void]$Datatable.Columns.Add('Parent',[int])
[void]$Datatable.Columns.Add('Next',[int])
[void]$Datatable.Columns.Add('LinkParent',[int])
[void]$Datatable.Columns.Add('LinkChild',[int])
[void]$Datatable.Columns.Add('Type',[int])
[void]$Datatable.Columns.Add('CharacterNameHidden',[string])
[void]$Datatable.Columns.Add('ThingType',[int])
[void]$Datatable.Columns.Add('VehicleTypeHidden',[string])
[void]$Datatable.Columns.Add('State',[int])
[void]$Datatable.Columns.Add('Flag',[int])
[void]$Datatable.Columns.Add('LinkSame',[int])
[void]$Datatable.Columns.Add('LinkSameGroup',[int])
[void]$Datatable.Columns.Add('Radius',[int])
[void]$Datatable.Columns.Add('ThingOffset',[int])
[void]$Datatable.Columns.Add('map_posx',[int32])
[void]$Datatable.Columns.Add('map_posy',[int64])
[void]$Datatable.Columns.Add('map_posz',[int32])
[void]$Datatable.Columns.Add('Group',[int])
[void]$Datatable.Columns.Add('GroupName',[string])
[void]$Datatable.Columns.Add('WeaponsCarried',[long])
[void]$Datatable.Columns.Add('WeaponsInventory',[string])
[void]$Datatable.Columns.Add('ModsInventory',[string])
[void]$Datatable.Columns.Add('Frame',[int])
[void]$Datatable.Columns.Add('StartFrame',[int])
[void]$Datatable.Columns.Add('Timer1',[int])
[void]$Datatable.Columns.Add('StartTimer1',[int])
[void]$Datatable.Columns.Add('VX',[long])
[void]$Datatable.Columns.Add('VY',[long])
[void]$Datatable.Columns.Add('VZ',[long])
[void]$Datatable.Columns.Add('Speed',[int])
[void]$Datatable.Columns.Add('Health',[int])
[void]$Datatable.Columns.Add('Owner',[int])
[void]$Datatable.Columns.Add('PathOffset',[int])
[void]$Datatable.Columns.Add('SubState',[int])
[void]$Datatable.Columns.Add('PTarget',[int])
[void]$Datatable.Columns.Add('Flag2',[long])
[void]$Datatable.Columns.Add('GotoThingIndex',[int])
[void]$Datatable.Columns.Add('OldTarget',[int])
[void]$Datatable.Columns.Add('PathIndex',[int])
[void]$Datatable.Columns.Add('UniqueID',[int])
[void]$Datatable.Columns.Add('EffectiveGroup',[int])
[void]$Datatable.Columns.Add('ComHead',[int])
[void]$Datatable.Columns.Add('ComCur',[int])
[void]$Datatable.Columns.Add('SpecialTimer',[int])
[void]$Datatable.Columns.Add('Angle',[int])
[void]$Datatable.Columns.Add('WeaponTurn',[int])
[void]$Datatable.Columns.Add('Brightness',[int])
[void]$Datatable.Columns.Add('ComRange',[int])
[void]$Datatable.Columns.Add('BumpMode',[int])
[void]$Datatable.Columns.Add('BumpCount',[int])
[void]$Datatable.Columns.Add('Vehicle',[int])
[void]$Datatable.Columns.Add('LinkPassenger',[int])
[void]$Datatable.Columns.Add('Within',[int])
[void]$Datatable.Columns.Add('LastDist',[int])
[void]$Datatable.Columns.Add('ComTimer',[int])
[void]$Datatable.Columns.Add('Timer2',[int])
[void]$Datatable.Columns.Add('StartTimer2',[int])
[void]$Datatable.Columns.Add('AnimMode',[int])
[void]$Datatable.Columns.Add('OldAnimMode',[int])
[void]$Datatable.Columns.Add('OnFace',[int])
[void]$Datatable.Columns.Add('UMod',[int])
[void]$Datatable.Columns.Add('Mood',[int])
[void]$Datatable.Columns.Add('FId0',[int])
[void]$Datatable.Columns.Add('FId1',[int])
[void]$Datatable.Columns.Add('FId2',[int])
[void]$Datatable.Columns.Add('FId3',[int])
[void]$Datatable.Columns.Add('FId4',[int])
[void]$Datatable.Columns.Add('Shadows',[int])
[void]$Datatable.Columns.Add('RecoilTimer',[int])
[void]$Datatable.Columns.Add('MaxHealth',[int])
[void]$Datatable.Columns.Add('Flag3',[int])
[void]$Datatable.Columns.Add('OldSubType',[int])
[void]$Datatable.Columns.Add('ShieldEnergy',[int])
[void]$Datatable.Columns.Add('ShieldGlowTimer',[int])
[void]$Datatable.Columns.Add('WeaponDir',[int])
[void]$Datatable.Columns.Add('SpecialOwner',[int])
[void]$Datatable.Columns.Add('WorkPlace',[int])
[void]$Datatable.Columns.Add('LeisurePlace',[int])
[void]$Datatable.Columns.Add('WeaponTimer',[int])
[void]$Datatable.Columns.Add('Target2',[int])
[void]$Datatable.Columns.Add('MaxShieldEnergy',[int])
[void]$Datatable.Columns.Add('PersuadePower',[int])
[void]$Datatable.Columns.Add('MaxEnergy',[int])
[void]$Datatable.Columns.Add('Energy',[int])
[void]$Datatable.Columns.Add('RecoilDir',[int])
[void]$Datatable.Columns.Add('CurrentWeapon',[long])
[void]$Datatable.Columns.Add('GotoX',[int])
[void]$Datatable.Columns.Add('GotoZ',[int])
[void]$Datatable.Columns.Add('TempWeapon',[int])
[void]$Datatable.Columns.Add('Stamina',[int])
[void]$Datatable.Columns.Add('MaxStamina',[int])
[void]$Datatable.Columns.Add('ObjectWidth',[long])
[void]$Datatable.Columns.Add('Objectskewleft',[long])
[void]$Datatable.Columns.Add('Objectskewright',[long])
[void]$Datatable.Columns.Add('ObjectRoll',[long])
[void]$Datatable.Columns.Add('ObjectHeight',[long])
[void]$Datatable.Columns.Add('ObjectPitch',[long])
[void]$Datatable.Columns.Add('ObjectSkew2',[long])
[void]$Datatable.Columns.Add('ObjectStretch',[long])
[void]$Datatable.Columns.Add('ObjectLength',[long])
[void]$Datatable.Columns.Add('Invisible',[boolean])
[void]$Datatable.Columns.Add('Dead',[boolean])
[void]$Datatable.Columns.Add('InsideBuilding',[boolean])

$commandTable = New-Object System.Data.DataTable

[void]$commandTable.Columns.Add('CommandNo',[int])
[void]$commandTable.Columns.Add('Next',[int])
[void]$commandTable.Columns.Add('OtherThing',[int])
[void]$commandTable.Columns.Add('X',[long])
[void]$commandTable.Columns.Add('Y',[long])
[void]$commandTable.Columns.Add('Z',[long])
[void]$commandTable.Columns.Add('Type',[int])
[void]$commandTable.Columns.Add('CommandNameHidden',[string])
[void]$commandTable.Columns.Add('SubType',[int])
[void]$commandTable.Columns.Add('Arg1',[int])
[void]$commandTable.Columns.Add('Arg2',[int])
[void]$commandTable.Columns.Add('Time',[int])
[void]$commandTable.Columns.Add('MyThing',[int])
[void]$commandTable.Columns.Add('Parent',[int])
[void]$commandTable.Columns.Add('Flags',[int32])
[void]$commandTable.Columns.Add('Field_1C',[int32])

$groupsTable = New-Object System.Data.DataTable

[void]$groupsTable.Columns.Add('GroupNo',[int])
[void]$groupsTable.Columns.Add('Groupname',[string])


$itemsTable = New-Object System.Data.DataTable

[void]$itemsTable.Columns.Add('ItemParent',[int])
[void]$itemsTable.Columns.Add('ItemNext',[int])
[void]$itemsTable.Columns.Add('ItemLinkParent',[int])
[void]$itemsTable.Columns.Add('ItemLinkChild',[int])
[void]$itemsTable.Columns.Add('ItemSubType',[int])
[void]$itemsTable.Columns.Add('ItemType',[int])
[void]$itemsTable.Columns.Add('ItemName',[string])
[void]$itemsTable.Columns.Add('ItemState',[int])
[void]$itemsTable.Columns.Add('ItemFlag',[int])
[void]$itemsTable.Columns.Add('ItemLinkSame',[int])
[void]$itemsTable.Columns.Add('ItemObject',[int])
[void]$itemsTable.Columns.Add('ItemRadius',[int])
[void]$itemsTable.Columns.Add('ItemThingOffset',[int])
[void]$itemsTable.Columns.Add('ItemX',[int32])
[void]$itemsTable.Columns.Add('ItemY',[int32])
[void]$itemsTable.Columns.Add('ItemZ',[int32])
[void]$itemsTable.Columns.Add('ItemFrame',[int])
[void]$itemsTable.Columns.Add('ItemStartFrame',[int])
[void]$itemsTable.Columns.Add('ItemTimer1',[int])
[void]$itemsTable.Columns.Add('ItemStartTimer1',[int])
[void]$itemsTable.Columns.Add('ItemWeaponType',[int])
[void]$itemsTable.Columns.Add('ItemLastFired',[int])
[void]$itemsTable.Columns.Add('ItemAmmo',[int])
[void]$itemsTable.Columns.Add('ItemOwner',[int])
[void]$itemsTable.Columns.Add('ItemOnFace',[int])
[void]$itemsTable.Columns.Add('Itemfield_38',[int])
[void]$itemsTable.Columns.Add('ItemUniqueId',[int])

$weaponsTable = New-Object System.Data.DataTable
[void]$weaponsTable.Columns.Add('Uzi',[boolean])
[void]$weaponsTable.Columns.Add('Minigun',[boolean])
[void]$weaponsTable.Columns.Add('PulseLaser',[boolean])
[void]$weaponsTable.Columns.Add('ElectronMace',[boolean])
[void]$weaponsTable.Columns.Add('Launcher',[boolean])
[void]$weaponsTable.Columns.Add('NuclearGrenade',[boolean])
[void]$weaponsTable.Columns.Add('Persuadertron',[boolean])
[void]$weaponsTable.Columns.Add('Flamer',[boolean])
[void]$weaponsTable.Columns.Add('Disrupter',[boolean])
[void]$weaponsTable.Columns.Add('PsychoGas',[boolean])
[void]$weaponsTable.Columns.Add('KnockoutGas',[boolean])
[void]$weaponsTable.Columns.Add('IonMine',[boolean])
[void]$weaponsTable.Columns.Add('HighExplosive',[boolean])
[void]$weaponsTable.Columns.Add('LRRifle',[boolean])
[void]$weaponsTable.Columns.Add('SatelliteRain',[boolean])
[void]$weaponsTable.Columns.Add('PlasmaLance',[boolean])
[void]$weaponsTable.Columns.Add('RazorWire',[boolean])
[void]$weaponsTable.Columns.Add('GravitonGun',[boolean])
[void]$weaponsTable.Columns.Add('PersuadertronII',[boolean])
[void]$weaponsTable.Columns.Add('StasisField',[boolean])
[void]$weaponsTable.Columns.Add('Chromotap',[boolean])
[void]$weaponsTable.Columns.Add('Displacertron',[boolean])
[void]$weaponsTable.Columns.Add('CerberusIFF',[boolean])
[void]$weaponsTable.Columns.Add('Medikit',[boolean])
[void]$weaponsTable.Columns.Add('Automedikit',[boolean])
[void]$weaponsTable.Columns.Add('TriggerWire',[boolean])
[void]$weaponsTable.Columns.Add('CloneShield',[boolean])

$groupsrelationsTable = New-Object System.Data.DataTable

for ($i = 0; $i -lt 32; $i++) {
    [void]$groupsrelationsTable.Columns.Add("KillOnSight$i",[boolean])
    }

for ($i = 0; $i -lt 32; $i++) {
    [void]$groupsrelationsTable.Columns.Add("KillIfWeaponOut$i",[boolean])
   }

for ($i = 0; $i -lt 32; $i++) {
    [void]$groupsrelationsTable.Columns.Add("KillIfArmed$i",[boolean])
   }

for ($i = 0; $i -lt 32; $i++) {
    [void]$groupsrelationsTable.Columns.Add("Truce$i",[boolean])
   }

$guardiansTable = New-Object System.Data.DataTable

for ($i = 0; $i -lt 8; $i++) {
    [void]$guardiansTable.Columns.Add("Guardian$i",[int])
   }


# ==================Forms start==================


[void][reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
$form = New-Object Windows.Forms.Form
$form.text = "SWInspector  v0.1  By Moburma"
$Form.Location= New-Object System.Drawing.Size(100,100)
$Form.Size= New-Object System.Drawing.Size(1920,900)

$Scriptpath = $PSCommandPath
$global:scriptdir = Split-Path $Scriptpath -Parent #Use script directory as default directory
#Temporary splash screen if no level loaded
$mapimgfile = (get-item "$scriptdir\SWMaps\Splash.png")
$img = [System.Drawing.Image]::Fromfile($mapimgfile);

[System.Windows.Forms.Application]::EnableVisualStyles();
#Define picturebox for map image
$global:pictureBox = New-Object Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Size(10,10)
$pictureBox.Size = New-Object System.Drawing.Size($img.Width,$img.Height)
$pictureBox.Image = $img
$Form.controls.add($pictureBox)
#Setup Mouse coordinate box
$mousecoordlabel = New-Object Windows.Forms.Label
$mousecoordlabel.Location = New-Object Drawing.Point 10,310
$mousecoordlabel.Text = "Mouse Coordinates:"
$mousecoordlabel.AutoSize = $true
$form.Controls.Add($mousecoordlabel)

$global:freezeCoordinates = $false
$lastMousePosition = $null
$pictureBox.Add_MouseDown({  #Mouse click to freeze map coordinates
    param (
        [System.Object]$sender,
        [System.Windows.Forms.MouseEventArgs]$e
    )
    if ($global:freezeCoordinates) {
        # Unfreeze coordinates
        $global:freezeCoordinates = $false
        UpdateCoordinatesLabel $e.X $e.Y
    } else {
        # Freeze coordinates
        $global:freezeCoordinates = $true
        $global:lastMousePosition = $e.Location
    }
})

function UpdateCoordinatesLabel($x, $y) {

    $mousecoordlabel.Text = "T:  X: $($x * 32768), Z: $($y * 32768)
O:  X: $($x * 128),      Z: $($y * 128)"

}


$pictureBox.add_MouseMove({
    param (
        [System.Object]$sender,
        [System.Windows.Forms.MouseEventArgs]$e
    )
    if ($global:freezeCoordinates) {
        # If coordinates are frozen, use last mouse position
        $x = $global:lastMousePosition.X
        $y = $global:lastMousePosition.Y
    } else {
        # Otherwise, get current mouse position
        $x = $e.X
        $y = $e.Y
    }
    UpdateCoordinatesLabel $x $y
})

#Set level file info box
$Levelinfobox = New-Object Windows.Forms.Label
$Levelinfobox.Location = New-Object Drawing.Point 10,270
$Levelinfobox.Size = New-Object Drawing.Point 250,80
$Levelinfobox.text ="$filename 
City: None
"

$Form.controls.add($Levelinfobox)

$global:Thingcount = 0
$global:CommandCount = 0
$global:ItemCount = 0

$ThingCountlabel = New-Object Windows.Forms.Label
$ThingCountlabel.Location = New-Object Drawing.Point 10,350
$ThingCountlabel.Text = "Things: $Thingcount 
Commands: $Commandcount 
Items: $ItemCount"
$ThingCountlabel.AutoSize = $true
$form.Controls.Add($ThingCountlabel)


#Load Button

$LoadButton_click = {LoadLevel -newMap 0}

$LoadButton = New-Object System.Windows.Forms.Button
$LoadButton.Location = New-Object System.Drawing.Size(10,400)
$LoadButton.Size = New-Object System.Drawing.Size(50,23)
$LoadButton.Text = "Load"
$Form.Controls.Add($LoadButton)
$LoadButton.Add_Click($LoadButton_Click)

#SaveButton

$SaveButton_click = {SaveFile}

$SaveButton = New-Object System.Windows.Forms.Button
$SaveButton.Location = New-Object System.Drawing.Size(70,400)
$SaveButton.Size = New-Object System.Drawing.Size(50,23)
$SaveButton.Text = "Save"
$Form.Controls.Add($SaveButton)
$SaveButton.Add_Click($SaveButton_Click)

#New Level button

$NewButton_click = {NewLevel}

$NewButton = New-Object System.Windows.Forms.Button
$NewButton.Location = New-Object System.Drawing.Size(130,400)
$NewButton.Size = New-Object System.Drawing.Size(50,23)
$NewButton.Text = "New"
#$Form.Controls.Add($NewButton)
$NewButton.Add_Click($NewButton_Click)


#Clear Row Button

$ClearButton_click = {ClearRow}

$ClearButton = New-Object System.Windows.Forms.Button
$ClearButton.Location = New-Object System.Drawing.Size(10,430)
$ClearButton.Size = New-Object System.Drawing.Size(70,23)
$ClearButton.Text = "Del Thing"
$Form.Controls.Add($ClearButton)
$ClearButton.Add_Click($ClearButton_Click)

function Checkbox_StateChanged ($checkbox) {
    
    #write-host "box $($checkbox) was ticked"
    $weaponName = $checkbox.Text

    if ($checkbox.Checked) {
        #Write-Host "Checkbox '$weaponName' is checked."
        $global:weapTotal = $global:weapTotal + (weaponNumber $checkbox.text)
        #write-host $global:weapTotal 
    } else {
       # Write-Host "Checkbox '$weaponName' is unchecked."
        $global:weapTotal = $global:weapTotal - (weaponNumber $checkbox.text)
        #write-host $global:weapTotal 
    }
}

function ModCheckbox_StateChanged ($checkbox) {
    
    #write-host "box $($checkbox) was ticked"
    $modName = $checkbox.Text

    if ($checkbox.Checked) {
        #Write-Host "Checkbox '$weaponName' is checked."
        $global:modTotal = $global:modTotal + (modNumber $checkbox.text)
        #write-host $global:weapTotal 
    } else {
       # Write-Host "Checkbox '$weaponName' is unchecked."
        $global:modTotal = $global:modTotal - (modNumber $checkbox.text)
        #write-host $global:weapTotal 
    }
}

#Edit Weapons button

$Weaponsbutton = New-Object System.Windows.Forms.Button
$Weaponsbutton.Text = "Edit Weapons"
$Weaponsbutton.Location = New-Object System.Drawing.Point(10,460)
$Weaponsbutton.Size = New-Object System.Drawing.Size(90,23)
$Form.Controls.Add($Weaponsbutton)

# Checkbox State Change Event Handler

$Weaponsbutton.Add_Click({

                # Create Form
        $WeaponsForm = New-Object System.Windows.Forms.Form
        $WeaponsForm.Text = "Weapons Form"
        $WeaponsForm.Size = New-Object System.Drawing.Size(800, 200)
        $WeaponsForm.StartPosition = "CenterScreen"

        # Create TableLayoutPanel
        $tableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
        $tableLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
        $tableLayoutPanel.RowCount = 4
        $tableLayoutPanel.ColumnCount = 7
        $checkcount = 0

        $WeaponsForm.Add_Closing({
            $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[19].Value = $global:weapTotal 
            $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value = (weaponInventory $global:weapTotal).trim()
        })

        $global:weapTotal = $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[19].Value

        # Add Checkboxes to TableLayoutPanel
        for ($row = 0; $row -lt $tableLayoutPanel.RowCount; $row++) {
            for ($col = 0; $col -lt $tableLayoutPanel.ColumnCount; $col++) {
                $checkbox = New-Object System.Windows.Forms.CheckBox

                if (($row * $tableLayoutPanel.ColumnCount + $col + 1)-lt 14){
                $checkitem = IdentifyItem $($row * $tableLayoutPanel.ColumnCount + $col + 1)
                $checkbox.Text = "$checkitem"
                }
                elseif (($row * $tableLayoutPanel.ColumnCount + $col + 1) -ge 14 -and ($row * $tableLayoutPanel.ColumnCount + $col + 1) -lt 18){
                    $checkitem = IdentifyItem $($row * $tableLayoutPanel.ColumnCount + $col + 2)
                    $checkbox.Text = "$checkitem"
                }
                elseif (($row * $tableLayoutPanel.ColumnCount + $col + 1) -ge 18 -and ($row * $tableLayoutPanel.ColumnCount + $col + 1) -lt 21){
                    $checkitem = IdentifyItem $($row * $tableLayoutPanel.ColumnCount + $col + 3)
                    $checkbox.Text = "$checkitem"
                }
                elseif (($row * $tableLayoutPanel.ColumnCount + $col + 1) -ge 21 -and ($row * $tableLayoutPanel.ColumnCount + $col + 1) -lt 28){
                    $checkitem = IdentifyItem $($row * $tableLayoutPanel.ColumnCount + $col + 4)
                    $checkbox.Text = "$checkitem"
                }
                
                if ($checkcount -eq 0 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Uzi*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 1 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Minigun*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 2 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Pulse Laser*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 3 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Electron Mace*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 4 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Launcher*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 5 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Nuclear Grenade*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 6 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Persuadertron*" -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -notlike "*Persuadertron II*"){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 7 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Flamer*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 8 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Disrupter*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 9 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Psycho Gas*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 10 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Knockout Gas*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 11 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Ion Mine*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 12 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Explosives*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 13 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*LR Rifle*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 14 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Satellite Rain*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 15 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Plasma Lance*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 16 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Razor Wire*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 17 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Graviton Gun*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 18 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Persuadertron II*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 19 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Stasis Field*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 20 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Chromotap*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 21 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Displacertron*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 22 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Cerberus IFF*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 23 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Medikit*" -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -notlike "*autoMedikit*"){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 24 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*AutoMedikit*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 25 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Triggerwire*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 26 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[20].Value -like "*Clone Shield*" ){
                    $checkbox.CheckState = 1 
                }
                if ($checkcount -eq 27){
                    $checkbox.Visible = $false

                }

                # Add event handler to handle checkbox state change

                $checkbox.Add_CheckedChanged({
                     Checkbox_StateChanged($this); 
                })
                
                
                $tableLayoutPanel.Controls.Add($checkbox, $col, $row)

                $checkcount = $checkcount + 1
            }
        }

        
        # Add TableLayoutPanel to Form
        $WeaponsForm.Controls.Add($tableLayoutPanel)

        # Show Form
        $WeaponsForm.ShowDialog()
            $WeaponsForm.Dispose()

})

$Modsbutton = New-Object System.Windows.Forms.Button
$Modsbutton.Text = "Edit Mods"
$Modsbutton.Location = New-Object System.Drawing.Point(100,460)
$Modsbutton.Size = New-Object System.Drawing.Size(70,23)
$Form.Controls.Add($Modsbutton)

$Modsbutton.Add_Click({

    # Create Form
$ModsForm = New-Object System.Windows.Forms.Form
$ModsForm.Text = "Mods Form"
$ModsForm.Size = New-Object System.Drawing.Size(800, 200)
$ModsForm.StartPosition = "CenterScreen"

# Create TableLayoutPanel
$tableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$tableLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayoutPanel.RowCount = 3
$tableLayoutPanel.ColumnCount = 6
$checkcount = 0

$ModsForm.Add_Closing({
$datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[60].Value = $global:modTotal 
$datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value = (modInventory $global:modTotal).trim()
})

$global:modTotal = $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[60].Value

# Add Checkboxes to TableLayoutPanel
for ($row = 0; $row -lt $tableLayoutPanel.RowCount; $row++) {
for ($col = 0; $col -lt $tableLayoutPanel.ColumnCount; $col++) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $modsList = @('Legs 1', 'Legs 2', 'Legs 3', 'Arms 1', 'Arms 2', 'Arms 3', 'Body 1', 'Body 2', 'Body 3', 'Brain 1', 'Brain 2', 'Brain 3', 'Epidermis 1', 'Epidermis 2', 'Epidermis 3', 'Epidermis 4')

    $checkbox.Text = $modsList[$checkcount]    

    if ($checkcount -eq 0 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Legs 1*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 1 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Legs 2*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 2 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Legs 3*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 3 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Arms 1*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 4 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Arms 2*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 5 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Arms 3*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 6 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Body 1*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 7 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Body 2*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 8 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Body 3*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 9 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Brain 1*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 10 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Brain 2*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 11 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Brain 3*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 12 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Epidermis 1*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 13 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Epidermis 2*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 14 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Epidermis 3*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -eq 15 -AND $datagridview.Rows[$datagridview.CurrentCell.RowIndex].Cells[21].Value -like "*Epidermis 4*" ){
        $checkbox.CheckState = 1 
    }
    if ($checkcount -gt 15){
        $checkbox.Visible = $false

    }


    # Add event handler to handle checkbox state change

    $checkbox.Add_CheckedChanged({
         ModCheckbox_StateChanged($this); 
    })
    
    
    $tableLayoutPanel.Controls.Add($checkbox, $col, $row)

    $checkcount++
}
}


# Add TableLayoutPanel to Form
$modsForm.Controls.Add($tableLayoutPanel)

# Show Form
$modsForm.ShowDialog()
$modsForm.Dispose()

})

$CloneThing_click = {CloneThingRow}

$CloneThing = New-Object System.Windows.Forms.Button
$CloneThing.Location = New-Object System.Drawing.Size(80,430)
$CloneThing.Size = New-Object System.Drawing.Size(80,23)
$CloneThing.Text = "Clone Thing"
$Form.Controls.Add($CloneThing)
$CloneThing.Add_Click($CloneThing_Click)

$PasteThingCo_click = {PasteThingCoords}

$PasteThingCo = New-Object System.Windows.Forms.Button
$PasteThingCo.Location = New-Object System.Drawing.Size(160,430)
$PasteThingCo.Size = New-Object System.Drawing.Size(110,23)
$PasteThingCo.Text = "Paste Thing Coord"
$Form.Controls.Add($PasteThingCo)
$PasteThingCo.Add_Click($PasteThingCo_Click)

$CloneNewCommand_click = {CloneCommandNewRow}

$CloneNewCommand = New-Object System.Windows.Forms.Button
$CloneNewCommand.Location = New-Object System.Drawing.Size(110,490)
$CloneNewCommand.Size = New-Object System.Drawing.Size(150,23)
$CloneNewCommand.Text = "Clone To New Command"
$Form.Controls.Add($CloneNewCommand)
$CloneNewCommand.Add_Click($CloneNewCommand_Click)


$CloneCommand_click = {CloneCommandRow}

$CloneCommand = New-Object System.Windows.Forms.Button
$CloneCommand.Location = New-Object System.Drawing.Size(10,490) 
$CloneCommand.Size = New-Object System.Drawing.Size(100,23)
$CloneCommand.Text = "Clone Command"
$Form.Controls.Add($CloneCommand)
$CloneCommand.Add_Click($CloneCommand_Click)

$StepComForward_click = {StepCommandForward}

$StepComForward = New-Object System.Windows.Forms.Button
$StepComForward.Location = New-Object System.Drawing.Size(220,620)
$StepComForward.Size = New-Object System.Drawing.Size(50,23)
$StepComForward.Text = "Com >"
$Form.Controls.Add($StepComForward)
$StepComForward.Add_Click($StepComForward_Click)

$StepComBack_click = {StepCommandBack}

$StepComBack = New-Object System.Windows.Forms.Button
$StepComBack.Location = New-Object System.Drawing.Size(220,650)
$StepComBack.Size = New-Object System.Drawing.Size(50,23)
$StepComBack.Text = "Com <"
$Form.Controls.Add($StepComBack)
$StepComBack.Add_Click($StepComBack_Click)

$Sorttable_click = {SortLinkSameGroup}

$Sorttable = New-Object System.Windows.Forms.Button
$Sorttable.Location = New-Object System.Drawing.Size(90,550)
$Sorttable.Size = New-Object System.Drawing.Size(80,23)
$Sorttable.Text = "Sort table"

$Sorttable.Add_Click($Sorttable_Click)

#Chartype arrays for combobox updates

$CharType1 =  @('80', '1', '0', '48', '48', '612', '1500', '1500', '1536', '1536', '2048', '2048', '4096', '4096') #Agent
$CharType2 =  @('100', '581', '112', '48', '48', '612', '1500', '1500', '1536', '1536', '2048', '2048', '4096', '4096') #Zealot
$CharType3 =  @('80', '1193', '240', '48', '48', '612', '1275', '1275', '1310', '1310', '1502', '1502', '2048', '2048') #Unguided Female
$CharType4 =  @('100', '1537', '320', '48', '48', '212', '100', '100', '100', '100', '100', '100', '800', '800') #Civ - Briefcase Man
$CharType5 =  @('100', '1937', '400', '48', '48', '200', '100', '100', '100', '100', '100', '100', '800', '800') #Civ - White Dress Woman
$CharType6 =  @('100', '2681', '560', '48', '48', '612', '1275', '1275', '1500', '1500', '1502', '1502', '900', '900') #Soldier/Mercenary
$CharType7 =  @('384', '4551', '1039', '48', '48', '562', '7000', '7000', '2000', '2000', '4002', '4002', '800', '800') #Mechanical Spider
$CharType8 =  @('80', '2281', '480', '48', '48', '362', '600', '600', '400', '400', '601', '601', '800', '800') #Police
$CharType9 =  @('80', '793', '160', '48', '48', '412', '900', '900', '786', '786', '1202', '1202', '4048', '4048') #Unguided Male
$CharType10 =  @('100', '3081', '640', '48', '48', '212', '200', '200', '100', '100', '100', '100', '600', '600') #Scientist
$CharType11 =  @('100', '3465', '720', '48', '48', '312', '600', '600', '524', '524', '601', '601', '4048', '4048') #Shady Guy
$CharType12 =  @('100', '3865', '800', '48', '48', '812', '4250', '4250', '2560', '2560', '2560', '2560', '2048', '2048') #Elite Zealot
$CharType13 =  @('0', '4973', '1330', '48', '48', '200', '100', '100', '100', '100', '100', '100', '400', '400') #Civ - Blonde Woman 1
$CharType14 =  @('100', '5371', '1426', '48', '48', '242', '110', '110', '100', '100', '100', '100', '800', '800') #Civ - Leather Jacket Man

$Chararrays = @($CharType1, $CharType2, $CharType3, $CharType4, $CharType5, $CharType6, $CharType7, $CharType8, $CharType9, $CharType10, $CharType11, $CharType12, $CharType13, $CharType14 )


#Main Datagrid cell edited activities

$datagridview_CellEndEdit=[System.Windows.Forms.DataGridViewCellEventHandler]{
    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'CharacterName') #If updating CharacterName, update Type to match
        {
            
            $datagridview.Rows[$_.RowIndex].Cells[4].Value = identifycharacter($datagridview.Rows[$_.RowIndex].Cells[$_.ColumnIndex].Value)

            if ($datagridview.Rows[$_.RowIndex].Cells[4].Value -lt 16){  #If a character and not a vehicle, add stats automatically
                for ($i=22; $i -lt 91; $i++) {  #Zero out the rest
                    $datagridview.Rows[$_.RowIndex].Cells[$i].Value = 0
                }
                $datagridview.Rows[$_.RowIndex].Cells[12].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][0] #Update Radius
                $datagridview.Rows[$_.RowIndex].Cells[22].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][1] #Update Frame
                $datagridview.Rows[$_.RowIndex].Cells[23].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][2] #Update StartFrame
                $datagridview.Rows[$_.RowIndex].Cells[24].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][3] #Update Timer1
                $datagridview.Rows[$_.RowIndex].Cells[25].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][4] #Update StartTimer1
                $datagridview.Rows[$_.RowIndex].Cells[29].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][5] #Update Speed
                $datagridview.Rows[$_.RowIndex].Cells[30].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][6] #Update Health
                $datagridview.Rows[$_.RowIndex].Cells[69].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][7] #Update MaxHealth
                $datagridview.Rows[$_.RowIndex].Cells[72].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][8] #Update ShieldEnergy
                $datagridview.Rows[$_.RowIndex].Cells[80].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][9] #Update MaxShieldEnergy
                $datagridview.Rows[$_.RowIndex].Cells[82].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][10] #Update MaxEnergy
                $datagridview.Rows[$_.RowIndex].Cells[83].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][11] #Update Energy
                $datagridview.Rows[$_.RowIndex].Cells[89].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][12] #Update Stamina
                $datagridview.Rows[$_.RowIndex].Cells[90].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][13] #Update Maxstamina
                $datagridview.Rows[$_.RowIndex].Cells[0].Value = 0 #parent
                $datagridview.Rows[$_.RowIndex].Cells[1].Value = 0 #child
                $datagridview.Rows[$_.RowIndex].Cells[8].Value = 0 #Update State
                $datagridview.Rows[$_.RowIndex].Cells[9].Value = 67108868 #Update Flag
                $datagridview.Rows[$_.RowIndex].Cells[19].Value = 0 #Zero out weaponscarried
                $datagridview.Rows[$_.RowIndex].Cells[26].Value = 0 #vx
                $datagridview.Rows[$_.RowIndex].Cells[27].Value = 0 #vy 
                $datagridview.Rows[$_.RowIndex].Cells[28].Value = 0 #vz
                $datagridview.Rows[$_.RowIndex].Cells[20].Value = "Unarmed"  #weapons inventory
                $datagridview.Rows[$_.RowIndex].Cells[21].Value = "No Mods"  #mod inventory

            }

            if ($datagridview.Rows[$_.RowIndex].Cells[4].Value -gt 15){
                $datagridview.Rows[$_.RowIndex].Cells[6].Value = 2    #Also reset the ThingType to vehicle value so we don't get errors 
            }
            Else{
                $datagridview.Rows[$_.RowIndex].Cells[6].Value = 3 #Set for a non-vehicle
            }
            

        }

    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'Type') #If updating Type, update CharacterName to match
        {

            $datagridview.Rows[$_.RowIndex].Cells[5].Value = identifycharacter($datagridview.Rows[$_.RowIndex].Cells[$_.ColumnIndex].Value)

            if ($datagridview.Rows[$_.RowIndex].Cells[4].Value -gt 15){
                $datagridview.Rows[$_.RowIndex].Cells[6].Value = 2    #Also reset the ThingType to vehicle value so we don't get errors 
            }
            Else{
                $datagridview.Rows[$_.RowIndex].Cells[6].Value = 3 #Set for a non-vehicle
            }

            if ($datagridview.Rows[$_.RowIndex].Cells[4].Value -lt 16){  #If a character and not a vehicle, add stats automatically
                $datagridview.Rows[$_.RowIndex].Cells[12].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][0] #Update Radius
                $datagridview.Rows[$_.RowIndex].Cells[22].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][1] #Update Frame
                $datagridview.Rows[$_.RowIndex].Cells[23].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][2] #Update StartFrame
                $datagridview.Rows[$_.RowIndex].Cells[24].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][3] #Update Timer1
                $datagridview.Rows[$_.RowIndex].Cells[25].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][4] #Update StartTimer1
                $datagridview.Rows[$_.RowIndex].Cells[29].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][5] #Update Speed
                $datagridview.Rows[$_.RowIndex].Cells[30].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][6] #Update Health
                $datagridview.Rows[$_.RowIndex].Cells[69].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][7] #Update MaxHealth
                $datagridview.Rows[$_.RowIndex].Cells[72].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][8] #Update ShieldEnergy
                $datagridview.Rows[$_.RowIndex].Cells[80].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][9] #Update MaxShieldEnergy
                $datagridview.Rows[$_.RowIndex].Cells[82].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][10] #Update MaxEnergy
                $datagridview.Rows[$_.RowIndex].Cells[83].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][11] #Update Energy
                $datagridview.Rows[$_.RowIndex].Cells[89].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][12] #Update Stamina
                $datagridview.Rows[$_.RowIndex].Cells[90].Value = $Chararrays[($datagridview.Rows[$_.RowIndex].Cells[4].Value -1)][13] #Update Maxstamina

            }
        }
       
    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'VehicleType') #If updating VEhicleType, update StartFrame to match
        {
            
            $datagridview.Rows[$_.RowIndex].Cells[23].Value = identifyvehicle($datagridview.Rows[$_.RowIndex].Cells[$_.ColumnIndex].Value)

            $datagridview.Rows[$_.RowIndex].Cells[6].Value = 2    #Also reset the ThingType to vehicle value so we don't get errors 

        }
    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'Invisible') { #Update Flag2 value if tickbox is changed
            if ($datagridview.Rows[$_.RowIndex].Cells[100].Value -eq $true -and $datagridview.Rows[$_.RowIndex].Cells[35].Value -lt 16777216){
                $datagridview.Rows[$_.RowIndex].Cells[35].Value = ($datagridview.Rows[$_.RowIndex].Cells[35].Value) + 16777216
            }
            if ($datagridview.Rows[$_.RowIndex].Cells[100].Value -eq $false -and $datagridview.Rows[$_.RowIndex].Cells[35].Value -ge 16777216){
                $datagridview.Rows[$_.RowIndex].Cells[35].Value = ($datagridview.Rows[$_.RowIndex].Cells[35].Value) - 16777216
            }
    }
    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'InsideBuilding') { #Update Flag2 value if tickbox is changed
        if ($datagridview.Rows[$_.RowIndex].Cells[102].Value -eq $true -and $datagridview.Rows[$_.RowIndex].Cells[35].Value -ne 536870912){
            $datagridview.Rows[$_.RowIndex].Cells[35].Value = ($datagridview.Rows[$_.RowIndex].Cells[35].Value) + 536870912
        }
        if ($datagridview.Rows[$_.RowIndex].Cells[102].Value -eq $false -and $datagridview.Rows[$_.RowIndex].Cells[35].Value -ge 536870912){
            $datagridview.Rows[$_.RowIndex].Cells[35].Value = ($datagridview.Rows[$_.RowIndex].Cells[35].Value) - 536870912
        }
}
    if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'Dead') { #Update Flag and State values if tickbox is changed
        if ($datagridview.Rows[$_.RowIndex].Cells[101].Value -eq $true -and $datagridview.Rows[$_.RowIndex].Cells[8].Value -ne 33){
            $datagridview.Rows[$_.RowIndex].Cells[9].Value = 67108870 #set Flag 1
            $datagridview.Rows[$_.RowIndex].Cells[8].Value = 13 #Set State
        }
        if ($datagridview.Rows[$_.RowIndex].Cells[101].Value -eq $true -and $datagridview.Rows[$_.RowIndex].Cells[8].Value -eq 33){
            $datagridview.Rows[$_.RowIndex].Cells[101].Value = $false #if user tries to make a vehicle dead, override this, not possible
        }
        if ($datagridview.Rows[$_.RowIndex].Cells[101].Value -eq $false -and $datagridview.Rows[$_.RowIndex].Cells[8].Value -ne 33){
            $datagridview.Rows[$_.RowIndex].Cells[9].Value =  67108868 #set Flag 1
            $datagridview.Rows[$_.RowIndex].Cells[8].Value = 0 #Set State
        }
}
        if ($datagridview.Columns[$_.ColumnIndex].Name -eq 'Group') { #Update Group name if group number is changed
      $datagridview.Rows[$_.RowIndex].Cells[18].Value = identifyGroup($datagridview.Rows[$_.RowIndex].Cells[17].Value)
}


    }

 $datagridview_CellClick=[System.Windows.Forms.DataGridViewCellEventHandler]{
    
      $transparent = [System.Drawing.Color]::FromArgb(0,255,0,255) 
    #$bmp.SetPixel(($lastx), ($lasty), ([System.Drawing.Color]::FromArgb(0, 255, 0, 255)))
    #$bmp.SetPixel(($lastx), ($lasty), ('Red'))

    if ($lastThing -gt 0){
    $bmp.SetPixel(($lastx), ($lasty), ((thingColour($lastThing))))}

    
        <#
   #$datagridview.Rows[$datagridview.CurrentRow.Index].DefaultCellStyle.BackColor = [System.Drawing.Color]::White;
    $global:lastx = $datagridview.Rows[$_.RowIndex].Cells[15].Value
    $global:lasty = $datagridview.Rows[$_.RowIndex].Cells[17].Value
    $global:lastThing = $datagridview.Rows[$_.RowIndex].Cells[1].Value

   $bmp.SetPixel(($datagridview.Rows[$_.RowIndex].Cells[15].Value), ($datagridview.Rows[$_.RowIndex].Cells[17].Value), 'Orange')
   
   
   $graphics.DrawImage($bmp, 0, 0, 256, 256)    #force redraw of map now user has clicked somewhere else
   $picturebox.refresh()#>

   #Move Commands view to ComHead for this Thing
   $selectedRowIndex = $dataGridView.CurrentCell.RowIndex
   $relatedID = $dataGridView.Rows[$selectedRowIndex].Cells['ComHead'].Value
   # Find the row in the Commands DataGridView with the related ID
   $relatedRowIndex = $commandGridview.Rows | Where-Object { $_.Cells['CommandNo'].Value -eq $relatedID } | ForEach-Object { $_.Index }

   # Select the corresponding row in the Commands DataGridView
   if ($relatedRowIndex -ne $null) {
       $commandGridview.CurrentCell = $commandGridview.Rows[$relatedRowIndex].Cells[0]
   }

    }

$dataGridView_CellBeginEdit=[System.Windows.Forms.DataGridViewCellCancelEventHandler]{
                   
      
    }



#Main Datagridview
$datagridview = New-Object System.Windows.Forms.DataGridView
$Form.controls.add($datagridview)
$datagridview.Location = New-Object System.Drawing.Point(280,10)
$datagridview.width = 1600
$datagridview.height = 500
$datagridview.Add_CellBeginEdit($datagridview_CellBeginEdit)
$datagridview.Add_CellEndEdit($datagridview_CellEndEdit)
$datagridview.Add_CellClick($datagridview_CellClick)


$DataBindingSource = New-Object System.Windows.Forms.BindingSource;
$DataBindingSource.DataSource = $Datatable;

$datagridview.DataSource = $DataBindingSource
$datagridview.Columns[0].Width = 40 #Size up main columns
$datagridview.Columns[1].Width = 40
$datagridview.Columns[2].Width = 40
$datagridview.Columns[3].Width = 60
$datagridview.Columns[4].Width = 60
$datagridview.Columns[5].Width = 100
$datagridview.Columns[6].Width = 60
$datagridview.Columns[7].Width = 100
$datagridview.Columns[8].Width = 40
$datagridview.Columns[9].Width = 40
$datagridview.Columns[10].Width = 40
$datagridview.Columns[11].Width = 40
$datagridview.Columns[100].Width = 25
$datagridview.Columns[101].Width = 25
$datagridview.Columns[102].Width = 25

$datagridview.Columns[5].Visible = $false; #Hide original charactername column
$datagridview.Columns[7].Visible = $false; #Hide original Vehicletype column
$datagridview.Columns[100].DisplayIndex = 0 #Put clickable boxes first
$datagridview.Columns[101].DisplayIndex = 1
$datagridview.Columns[102].DisplayIndex = 2
$datagridview.Columns[60].DisplayIndex = 19

$Charactercombo  = @("Invalid","Agent","Zealot", "Unguided Female", "Civ - Briefcase Man", "Civ - White Dress Woman", "Soldier/Mercenary", "Mechanical Spider", "Police", "Unguided Male", "Scientist", "Shady Guy", "Elite Zealot", "Civ - Blonde Woman 1", "Civ - Leather Jacket Man", "Civ - Blonde Woman 2", "Ground Car", "Flying vehicle", "Tank", "Ship", "Moon Mech")

$CharacterNameColumn = New-Object System.Windows.Forms.DataGridViewComboBoxColumn   #Define CharacterName Combobox
$CharacterNameColumn.width = 80
$CharacterNameColumn.HeaderText = "CharacterName"
$CharacterNameColumn.name = "CharacterName"
$CharacterNameColumn.DataPropertyName = 'CharacterNameHidden'
$CharacterNameColumn.DataSource = $Charactercombo 
[void]$datagridview.Columns.Add($CharacterNameColumn)
$CharacterNameColumn.DisplayIndex = 6
$datagridview.Columns[95].Width = 150
$VehicleCombo = @("N/A", "Civilian car (grey)", "DeLorean (grey)", "Bike", "Brown flyer", "Train engine", "Train carriage", "APC", "Large APC", "Police car", "Police Truck", "Small industrial vehicle", "Bullfrog Van", "Fire Engine", "Ambulance", "Taxi (Yellow)", "Barge", "Missile Frigate", "Luxury Yacht", "Tank", "Tank missile battery?", "Missile (small)", "Civilian car (Red)", "DeLorean (Yellow)", "Zealot Imperial Shuttle", "Taxi (Red)", "Missile (Large)", "Head of moon Mech", "Chest of mech?", "Bike (Metallic)", "Claw Mech (black)", "Claw Mech (Red)", "2000AD/Manga Truck", "Moon Mech leg", "Moon Mech leg", "Moon Mech leg", "Moon Mech leg", "Moon Mech Arm", "Moon Mech Arm", "Moon Mech Gun", "Moon Mech Gun")

$VehicleNameColumn = New-Object System.Windows.Forms.DataGridViewComboBoxColumn   #Define VehicleName Combobox
$VehicleNameColumn.width = 80
$VehicleNameColumn.HeaderText = "VehicleType"
$VehicleNameColumn.name = "VehicleType"
$VehicleNameColumn.DataPropertyName = 'VehicleTypeHidden'
$VehicleNameColumn.DataSource = $VehicleCombo
[void]$datagridview.Columns.Add($VehicleNameColumn)
$VehicleNameColumn.DisplayIndex = 8
$datagridview.Columns[96].Width = 150
# Commands View

$commandGridview_CellEndEdit=[System.Windows.Forms.DataGridViewCellEventHandler]{

    if ($commandGridview.Columns[$_.ColumnIndex].Name -eq 'CommandName') #If updating CommandName, update Type to match
    {   
        $commandGridview.Rows[$_.RowIndex].Cells[6].Value = identifycommand($commandGridview.Rows[$_.RowIndex].Cells[$_.ColumnIndex].Value)
    }

    if ($commandGridview.Columns[$_.ColumnIndex].Name -eq 'Type') #If updating Command type, update Name to match
    {   
        $commandGridview.Rows[$_.RowIndex].Cells[7].Value = identifycommand($commandGridview.Rows[$_.RowIndex].Cells[$_.ColumnIndex].Value)
    }
    if ($commandGridview.Rows[$_.RowIndex].Cells[0].Value -like ""){
        $commandGridview.Rows[$_.RowIndex].Cells[0].Value = ($commandGridview.Rows.count -2)
    }
    if ($commandGridview.Rows[$_.RowIndex].Cells[8].Value -like ""){
        $commandGridview.Rows[$_.RowIndex].Cells[8].Value = 0
        $commandGridview.Rows[$_.RowIndex].Cells[15].Value = 0
    }

}

$commandGridview_AddRow=[System.Windows.Forms.DataGridViewRowsAddedEventHandler]{

    $commandGridview.Rows[$_.RowIndex].Cells[0].Value = $commandGridview.Rows.count

}

$commandGridview = New-Object System.Windows.Forms.DataGridView
$Form.controls.add($commandGridview)
$commandGridview.Location = New-Object System.Drawing.Point(280,520)
$commandGridview.width = 1600
$commandGridview.height = 220
$commandGridview.Add_CellEndEdit($commandGridview_CellEndEdit)

$commandDataBindingSource = New-Object System.Windows.Forms.BindingSource;
$commandDataBindingSource.DataSource = $CommandTable;

$commandGridview.DataSource = $commandDataBindingSource
$commandGridview.Columns[0].Width = 80
$commandGridview.Columns[1].Width = 60
$commandGridview.Columns[2].Width = 70
$commandGridview.Columns[3].Width = 60
$commandGridview.Columns[4].Width = 60
$commandGridview.Columns[5].Width = 60
$commandGridview.Columns[6].Width = 60
$commandGridview.Columns[7].Width = 200

$commandCombo = @('NONE', 'STAY', 'GO_TO_POINT', 'GO_TO_PERSON', 'KILL_PERSON', 'KILL_MEM_GROUP', 'KILL_ALL_GROUP', 'PERSUADE_PERSON', 'PERSUADE_MEM_GROUP', 'PERSUADE_ALL_GROUP', 'BLOCK_PERSON', 'SCARE_PERSON', 'FOLLOW_PERSON', 'SUPPORT_PERSON', 'PROTECT_PERSON', 'HIDE', 'GET_ITEM', 'USE_WEAPON', 'DROP_SPEC_ITEM', 'AVOID_PERSON', 'WAND_AVOID_GROUP', 'DESTROY_BUILDING', '16', 'USE_VEHICLE', 'EXIT_VEHICLE', 'CATCH_TRAIN', 'OPEN_DOME', 'CLOSE_DOME', 'DROP_WEAPON', 'CATCH_FERRY', 'EXIT_FERRY', 'PING_EXIST', 'GOTOPOINT_FACE', 'SELF_DESTRUCT', 'PROTECT_MEM_G', 'RUN_TO_POINT', 'KILL_EVERYONE', 'GUARD_OFF', 'EXECUTE_COMS', '27', '32', 'WAIT_P_V_DEAD', 'WAIT_MEM_G_DEAD', 'WAIT_ALL_G_DEAD', 'WAIT_P_V_I_NEAR', 'WAIT_MEM_G_NEAR', 'WAIT_ALL_G_NEAR', 'WAIT_P_V_I_ARRIVES', 'WAIT_MEM_G_ARRIVE', 'WAIT_ALL_G_ARRIVE', 'WAIT_P_PERSUADED', 'WAIT_MEM_G_PERSUADED', 'WAIT_ALL_G_PERSUADED', 'WAIT_MISSION_SUCC', 'WAIT_MISSION_FAIL', 'WAIT_MISSION_START', 'WAIT_OBJECT_DESTROYED', 'WAIT_TIME', 'WAND_P_V_DEAD', 'WAND_MEM_G_DEAD', 'WAND_ALL_G_DEAD', 'WAND_P_V_I_NEAR', 'WAND_MEM_G_NEAR', 'WAND_ALL_G_NEAR', 'WAND_P_V_I_ARRIVES', 'WAND_MEM_G_ARRIVE', 'WAND_ALL_G_ARRIVE', 'WAND_P_PERSUADED', 'WAND_MEM_G_PERSUADED', 'WAND_ALL_G_PERSUADED', 'WAND_MISSION_SUCC', 'WAND_MISSION_FAIL', 'WAND_MISSION_START', 'WAND_OBJECT_DESTROYED', 'WAND_TIME', 'LOOP_COM', 'UNTIL_P_V_DEAD', 'UNTIL_MEM_G_DEAD', 'UNTIL_ALL_G_DEAD', 'UNTIL_P_V_I_NEAR', 'UNTIL_MEM_G_NEAR', 'UNTIL_ALL_G_NEAR', 'UNTIL_P_V_I_ARRIVES', 'UNTIL_MEM_G_ARRIVE', 'UNTIL_ALL_G_ARRIVE', 'UNTIL_P_PERSUADED', 'UNTIL_MEM_G_PERSUADED', 'UNTIL_ALL_G_PERSUADED', 'UNTIL_MISSION_SUCC', 'UNTIL_MISSION_FAIL', 'UNTIL_MISSION_START', 'UNTIL_OBJECT_DESTROYED', 'UNTIL_TIME', 'WAIT_OBJ', 'WAND_OBJ', 'UNTIL_OBJ', 'WITHIN_AREA', 'WITHIN_OFF', 'LOCK_BUILD', 'UNLOCK_BUILD', 'SELECT_WEAPON', 'HARD_AS_AGENT', 'UNTIL_G_NOT_SEEN', 'START_DANGER_MUSIC', 'PING_P_V', 'CAMERA_TRACK', 'UNTRUCE_GROUP', 'PLAY_SAMPLE', 'IGNORE_ENEMIES', 'FULL_STAMINA', 'CAMERA_ROTATE')

$CommandNameColumn = New-Object System.Windows.Forms.DataGridViewComboBoxColumn   #Define CharacterName Combobox
$CommandNameColumn.width = 80
$CommandNameColumn.HeaderText = "CommandName"
$CommandNameColumn.name = "commandName"
$CommandNameColumn.DataPropertyName = 'CommandNameHidden'
$CommandNameColumn.DataSource = $commandcombo 
[void]$commandGridview.Columns.Add($CommandNameColumn)
$CommandNameColumn.DisplayIndex = 7
$commandGridview.Columns[16].Width = 180

$commandGridview.Columns[0].Readonly = $true; # Don't let user change command numbers
$commandGridview.Columns[7].Visible = $false; # Hide original commandname column


$LevelGinfobox = New-Object Windows.Forms.Label
$LevelGinfobox.Location = New-Object Drawing.Point 10,705
$LevelGinfobox.Size = New-Object Drawing.Point 200,20
$LevelGinfobox.text ="Groups"
$Form.controls.add($LevelGinfobox)
$font = New-Object System.Drawing.Font($LevelGinfobox.Font, [System.Drawing.FontStyle]::Bold)
$LevelGinfobox.Font = $font

$groupsGridview = New-Object System.Windows.Forms.DataGridView
$Form.controls.add($groupsGridview)
$groupsGridview.Location = New-Object System.Drawing.Point(10,725)
$groupsGridview.width = 200
$groupsGridview.height = 220
$groupsGridview.Add_CellEndEdit($groupsGridview_CellEndEdit)

$groupsDataBindingSource = New-Object System.Windows.Forms.BindingSource;
$groupsDataBindingSource.DataSource = $groupsTable;

$groupsGridview.DataSource = $groupsDataBindingSource
$groupsGridview.Columns[0].Width = 20
$groupsGridview.Columns[1].Width = 135

$groupsGridView.Columns[0].Readonly = $true; # Don't let user change group numbers
$groupsGridView.AllowUserToAddRows = $false; # Don't let user add new rows

$groupsGridview_CellEndEdit=[System.Windows.Forms.DataGridViewCellEventHandler]{

    foreach ($row in $datagridview.Rows ){
        $row.Cells[18].Value = identifyGroup($row.Cells[17].Value)
        write-host triggered
    }

}


$Relationsbutton = New-Object System.Windows.Forms.Button
$Relationsbutton.Text = "Group Relations"
$Relationsbutton.Location = New-Object System.Drawing.Point(10,955)
$Relationsbutton.Size = New-Object System.Drawing.Size(100,23)
$Form.Controls.Add($Relationsbutton)

# Checkbox State Change Event Handler

$Relationsbutton.Add_Click({
    $Relationsform = New-Object System.Windows.Forms.Form
    $Relationsform.Text = "Edit Group Relationships"
    $Relationsform.Size = New-Object System.Drawing.Size(850, 350)
    #$Relationsform.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $Relationsform.MaximizeBox = $false
   
    $GroupNL = New-Object Windows.Forms.Label
    $GroupNL.Location = New-Object Drawing.Point 360,12
    $GroupNL.Size = New-Object Drawing.Point 40,20
    $GroupNL.text ="Group"
    $Relationsform.controls.add($GroupNL)

    $numericUpDown = New-Object System.Windows.Forms.NumericUpDown
    $numericUpDown.Location = New-Object System.Drawing.Point(400, 10)
    $numericUpDown.Width = 35
    $numericUpDown.Minimum = 0
    $numericUpDown.Maximum = 31
   
    $Relationsform.Controls.Add($numericUpDown)

    $numericUpDown.add_ValueChanged({
        # Update the checkboxes based on the NumericUpDown value
        $global:selectedRow = [int]$numericUpDown.Value 
        $row = $groupsrelationsTable.Rows[$selectedRow]
        $c = 0
        for ($i = 0; $i -lt 128; $i++) {
            if ($i -lt 32){
            $columnName = "KillOnSight$c"
            }
            elseif ($i -ge 32 -and $i -lt 64) {
                if ($c -eq 32){$c = 0}
                $columnName = "KillIfWeaponOut$c"
            }
            elseif ($i -ge 64 -and $i -lt 96) {
                if ($c -eq 32){$c = 0}
                $columnName = "KillIfArmed$c"
            }
            elseif ($i -ge 96 -and $i -lt 128) {
                if ($c -eq 32){$c = 0}
                $columnName = "Truce$c"
            }

            $c++
            
            $checkboxes[$i].Checked = $row[$columnName]
            if ($i -eq 0){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric0.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 1){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric1.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 2){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric2.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 3){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric3.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 4){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric4.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 5){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric5.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 6){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric6.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }
            Elseif ($i -eq 7){
                $gtext = "Guardian"+$i
   
                $GuardianNumeric7.value = [int]$guardiansTable.Rows[$selectedRow].$gtext
            }

        }


    })


    $KonSightL = New-Object Windows.Forms.Label
    $KonSightL.Location = New-Object Drawing.Point 10,60
    $KonSightL.Size = New-Object Drawing.Point 60,20
    $KonSightL.text ="K on Sight"
    $Relationsform.controls.add($KonSightL)

    $KGunOutL = New-Object Windows.Forms.Label
    $KGunOutL.Location = New-Object Drawing.Point 10,110
    $KGunOutL.Size = New-Object Drawing.Point 60,20
    $KGunOutL.text ="K Gun Out"
    $Relationsform.controls.add($KGunOutL)

    $KIfArmedL = New-Object Windows.Forms.Label
    $KIfArmedL.Location = New-Object Drawing.Point 10,160
    $KIfArmedL.Size = New-Object Drawing.Point 60,20
    $KIfArmedL.text ="K if Armed"
    $Relationsform.controls.add($KIfArmedL)

    $TruceL = New-Object Windows.Forms.Label
    $TruceL.Location = New-Object Drawing.Point 10,210
    $TruceL.Size = New-Object Drawing.Point 60,20
    $TruceL.text ="Truce"
    $Relationsform.controls.add($TruceL)

    $GuardianL = New-Object Windows.Forms.Label
    $GuardianL.Location = New-Object Drawing.Point 10,270
    $GuardianL.Size = New-Object Drawing.Point 70,20
    $GuardianL.text ="Guardians"
    $Relationsform.controls.add($GuardianL)

    $gx = 80

    for ($i = 0; $i -lt 8; $i++) {

    $Guardian = New-Object System.Windows.Forms.NumericUpDown
    $Guardian.Location = New-Object System.Drawing.Point($gx, 267)
    $Guardian.Width = 35
    $Guardian.Minimum = 0
    $Guardian.Maximum = 31
    $Guardian.name = "GuardianNumeric$i"

    $Guardian.add_ValueChanged({
    $guardnum = $this.name.Substring($this.name.Length - 1)
    $guardiansTable.Rows[$selectedRow]["Guardian$guardnum"] = $this.value
    })
   
    $GuardianNumeric = "GuardianNumeric"+$i

    if ($i -eq 0){
        $GuardianNumeric0 = $guardian
    }
    elseif ($i -eq 1){
        $GuardianNumeric1 = $guardian
    }
    elseif ($i -eq 2){
        $GuardianNumeric2 = $guardian
    }
    elseif ($i -eq 3){
        $GuardianNumeric3 = $guardian
    }
    elseif ($i -eq 4){
        $GuardianNumeric4 = $guardian
    }
    elseif ($i -eq 5){
        $GuardianNumeric5 = $guardian
    }
    elseif ($i -eq 6){
        $GuardianNumeric6 = $guardian
    }
    elseif ($i -eq 7){
        $GuardianNumeric7 = $guardian
    }

    $Relationsform.Controls.Add($Guardian)


    $gtext = "Guardian"+$i
 
                $Guardian.Value = [int]$guardiansTable.Rows[0].$gtext
    
    $gx = $gx + 40

    }    

    $checkboxes = @()

    function New-Checkbox ($x, $y, $cname) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.AutoSize = $true
    $checkbox.name = $cname
 
    return $checkbox
    }
    
    $y = 10
    # Create a loop to create four rows of 32 checkboxes
    for ($i = 0; $i -lt 4; $i++) {
    # Calculate the y coordinate for each row
    $x = 60
    $y = $y+ 50 #+ $i * 50
    for ($j = 0; $j -lt 32; $j++) {
    # Calculate the x coordinate for each checkbox
    
    if ($j -eq 4 -OR $j -eq 8 -OR $j -eq 12 -OR $j -eq 16 -OR $j -eq 20 -OR $j -eq 24 -OR $j -eq 28  ){
        $x = $x +30
    }
    Else{
        $x = $x + 20
    }
    # Create text for each checkbox
    # Create a checkbox and add it to the form

    if ($i -eq 0){
        $cname = "KillOnSight"
    }
    if ($i -eq 1){
        $cname = "KillIfWeaponOut"
    }
    if ($i -eq 2){
        $cname = "KillIfArmed"
    }
    if ($i -eq 3){
        $cname = "Truce"
    }

    $cname = "$cname"+"$j"

    $checkbox = New-Checkbox $x $y $cname
    
    $checkbox.Add_CheckedChanged({

        if ($this.Checked) {
            $checkname = $this.name
            $groupsrelationsTable.Rows[$selectedRow][$checkname] = $true
            
        } else {
            $checkname = $this.name
            $groupsrelationsTable.Rows[$selectedRow][$checkname] = $false
        }
        
            })

    $checkboxes += $checkbox
    $Relationsform.Controls.Add($checkbox)
    
    }
    }
        # Show the form
        $Relationsform.Add_Shown({$Relationsform.Activate()})
        [void] $Relationsform.ShowDialog()

    })


$itemsGridview = New-Object System.Windows.Forms.DataGridView
$Form.controls.add($itemsGridview)
$itemsGridview.Location = New-Object System.Drawing.Point(280,750)
$itemsGridview.width = 1600
$itemsGridview.height = 200
$itemsGridview.Add_CellEndEdit($itemsGridview_CellEndEdit)

$itemsDataBindingSource = New-Object System.Windows.Forms.BindingSource;
$itemsDataBindingSource.DataSource = $itemsTable;

$itemsGridview.DataSource = $itemsDataBindingSource
$itemsGridview.Columns[0].Width = 80
$itemsGridview.Columns[1].Width = 60
$itemsGridview.Columns[2].Width = 70
$itemsGridview.Columns[3].Width = 50
$itemsGridview.Columns[5].Width = 60
$itemsGridview.Columns[6].Width = 140
$itemsGridview.Columns[7].Width = 60

#AdvancedMode
advancedmode
$checkbox = New-Object System.Windows.Forms.CheckBox
$checkbox.Text = 'Advanced Mode'
$checkbox.Location = New-Object System.Drawing.Point(150,347)
$checkbox.Size = New-Object System.Drawing.Size(120,20)

# Register the event that triggers when the checkbox is checked or unchecked
$checkbox.Add_CheckStateChanged({
    advancedmode
})

# Add the checkbox to the form
$form.Controls.Add($checkbox)


$form.ShowDialog()