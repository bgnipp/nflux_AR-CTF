//
//  GameViewController.swift
//  tagginfun
//
//  Created by Bryan Gnipp on 9/29/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import CoreBluetooth
import MapKit
import AudioToolbox
import AVFoundation
import Foundation

var globalDefenseWonGame = false
var playerTagCount: Int = 0

var item1Enabled = true
var item2Enabled = true
var item3Enabled = true
var item4Enabled = true
var item5Enabled = true
var item6Enabled = true
var item7Enabled = true
var item8Enabled = true
var item9Enabled = true
var item10Enabled = true
var item11Enabled = true
var item12Enabled = true

var itemPrices = [Int]()
var itemsDisabled = []

var slot1Powerup = 0
var slot2Powerup = 0
var slot3Powerup = 0
var currentFunds = 0

var map3d = true
var quittingGame = false
var eventsArray = [String]()

var gameTimerCount: Int = 1500

//var testRadius: Double = 10

var testAnnType = ""
var testAnnCaption = ""
var testViewHidden = true

//player names
var offense1var: String = ""
var offense2var: String = ""
var offense3var: String = ""
var offense4var: String = ""
var offense5var: String = ""
var defense1var: String = ""
var defense2var: String = ""
var defense3var: String = ""
var defense4var: String = ""
var defense5var: String = ""

//player status, 0 = tagged (need to return to base), 1 = active, 2 = beginning game
var offense1Status = 2
var offense2Status = 2
var offense3Status = 2
var offense4Status = 2
var offense5Status = 2
var defense1Status = 2
var defense2Status = 2
var defense3Status = 2
var defense4Status = 2
var defense5Status = 2

var localPlayerStatus: Int = 2
var localPlayerPosition = ""
var playerCapturedPoint: String = "n"
var playerCapturedPointPosition = "n"
var puhack = false

var testFeaturesOn = false

extension String {
    func trunc(length: Int) -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length))
        } else {
            return self
        }
    }
}

class GameViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //temp (for video creaetion purposes)
    var tempdropcircle = MKCircle()
    var tempdropcircle2 = MKCircle()
    var tempdroppinlast = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptemp = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptempx = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var offensedroptempflag = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var defensedroptemp = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "temp")
    var pointdroptemp = CustomPin(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "Flag",
        subtitle: "Not captured")
    var circletemp = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: CLLocationDistance(5))

    
    //objects
    var inGameInfo = PFObject(withoutDataWithClassName: "inGameInfo", objectId: inGameInfoObjectID)
    var itemInfo = PFObject(withoutDataWithClassName: "itemInfo", objectId: itemInfoObjectID)
    
    //sounds
    var logicGamestart2 : AVAudioPlayer?
    var logicPowerUp : AVAudioPlayer?
    var logicScan : AVAudioPlayer?
    var logicLoseLife : AVAudioPlayer?
    var logicCapture : AVAudioPlayer?
    var logicCapturing2 : AVAudioPlayer?
    var logicCancel : AVAudioPlayer?
    var logicReign : AVAudioPlayer?
    var logicSFX1 : AVAudioPlayer?
    var logicSFX3 : AVAudioPlayer?
    var logicSFX4 : AVAudioPlayer?
    var logicGotTag : AVAudioPlayer?
    var backsound : AVAudioPlayer?
    var bomb : AVAudioPlayer?
    var chaching : AVAudioPlayer?
    var coin : AVAudioPlayer?
    var directitem : AVAudioPlayer?
    var entersound : AVAudioPlayer?
    var entersoundlow : AVAudioPlayer?
    var ghost : AVAudioPlayer?
    var itemdrop : AVAudioPlayer?
    var jammer : AVAudioPlayer?
    var lightning : AVAudioPlayer?
    var reach : AVAudioPlayer?
    var scansound : AVAudioPlayer?
    var setmine : AVAudioPlayer?
    var shield : AVAudioPlayer?
    var showtargetimageview : AVAudioPlayer?
    var sickle : AVAudioPlayer?
    var spybotsound : AVAudioPlayer?
    var superbomb : AVAudioPlayer?
    var bombtag : AVAudioPlayer?
    var lightningtag : AVAudioPlayer?
    var sickletag : AVAudioPlayer?
    var superbombtag : AVAudioPlayer?
    
    //lock in portrait orientation
    override func shouldAutorotate() -> Bool {
        return false }
    
    //mapview
    @IBOutlet var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var mapCamera = MKMapCamera()
    var pointCircle = MKCircle()
    var baseCircle = MKCircle()
    var currentLatitude: CLLocationDegrees = 0
    var currentLongitude: CLLocationDegrees = 0
    var initialMapSetup = false
    var initialMapSetup2 = false
//    var mapSetup = 0
    var readyToProcess = false
    
    //current region, 0 = neutral, 1 = base region, 2 = point region
    var localPlayerRegion: Int = 0
    
    //gameplay point vars
    var localPlayerCapturingPoint = false
    var localPlayerCapturedPoint = false
    var localPlayerWonGame = false
    var playerCapturingPoint: String =  "n"
    var randomPlayerWithPointTagged: String = "n"
    var postPlayerCapturedPointHeartbeat: String = "n"
    var postPlayerCapturingPointHeartbeat: String = "n"
    var playerCapturingPointHeartbeatParseClone: String = "n"
    var playerCapturedPointHeartbeatParseClone: String = "n"
    var playerCapturedPointErrorsLogged: Int = 0
    var playerCapturingPointErrorsLogged: Int = 0
    var randomPlayerCapturingPoint = "n"
    
    var intruderAlertResetCount = 0
    
    var flagNotInBaseCount = 0
    
    var playerCapturingPointSafetyCheckCount = 0
    var playerCapturedPointSafetyCheckCount = 0

    //gameplay tag vars
    var localPlayerTaggedBy = ""
    var playerTaggedBy = "n"
    var localPlayerTagged = ""
    var playerWithPointTagged = "n"
    var taggedPlayerHadPointCheck = "n"
    var T = []
    var T2 = []
    
    var tagNonce1: Int = 0
    var tagNonce2: Int = 0
    var tagNonce3: Int = 0
    var tagNonce1B: Int = 0
    var tagNonce2B: Int = 0
    var tagNonce3B: Int = 0
    
    var revealTagee1 = 0
    var revealTagee2 = 0
    var revealTagee3 = 0
    
    var revealTagee1Count = 0
    var revealTagee2Count = 0
    var revealTagee3Count = 0
    
    //player locations
    var offense1Lat: Double = 0
    var offense1Long: Double = 0
    var offense2Lat: Double = 0
    var offense2Long: Double = 0
    var offense3Lat: Double = 0
    var offense3Long: Double = 0
    var offense4Lat: Double = 0
    var offense4Long: Double = 0
    var offense5Lat: Double = 0
    var offense5Long: Double = 0
    var offense1Coordinates = CLLocationCoordinate2D()
    var offense2Coordinates = CLLocationCoordinate2D()
    var offense3Coordinates = CLLocationCoordinate2D()
    var offense4Coordinates = CLLocationCoordinate2D()
    var offense5Coordinates = CLLocationCoordinate2D()
    var offense1DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5DropPin = CustomPinBlueperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    var offense1XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5XDropPin = CustomPinBluepersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    var offense1flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 1")
    var offense2flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 2")
    var offense3flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 3")
    var offense4flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 4")
    var offense5flagDropPin = CustomPinBluepersonflag(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "offense 5")
    
    var pointDropPin = CustomPin(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Flag", subtitle: "Not captured")
    var flagAnnotationHidden = false
    var baseDropPin = CustomPinBase(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Offense's base")
    
    var defense1Lat: Double = 0
    var defense1Long: Double = 0
    var defense2Lat: Double = 0
    var defense2Long: Double = 0
    var defense3Lat: Double = 0
    var defense3Long: Double = 0
    var defense4Lat: Double = 0
    var defense4Long: Double = 0
    var defense5Lat: Double = 0
    var defense5Long: Double = 0
    var defense1Coordinates = CLLocationCoordinate2D()
    var defense2Coordinates = CLLocationCoordinate2D()
    var defense3Coordinates = CLLocationCoordinate2D()
    var defense4Coordinates = CLLocationCoordinate2D()
    var defense5Coordinates = CLLocationCoordinate2D()
    var defense1DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 1")
    var defense2DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 2")
    var defense3DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 3")
    var defense4DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 4")
    var defense5DropPin = CustomPinRedperson(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 5")
    var defense1XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 1")
    var defense2XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 2")
    var defense3XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 3")
    var defense4XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 4")
    var defense5XDropPin = CustomPinRedpersonX(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "defense 5")
    
    //UI label outlets
    @IBOutlet var RSSILabel: UILabel!
    @IBOutlet var thresholdLabel: UILabel!
    @IBOutlet var eventsLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var statusIcon: UIImageView!
    @IBOutlet var alertIconImageView: UIImageView!
    @IBOutlet var testButton: UIButton!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var lifeMeterImageView: UIImageView!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var powerup1ButtonOutlet: UIButton!
    @IBOutlet var powerup2ButtonOutlet: UIButton!
    @IBOutlet var powerup3ButtonOutlet: UIButton!
    @IBOutlet var targetImageView: UIImageView!
    @IBOutlet var itemButtonBackdropImageView: UIImageView!
    @IBOutlet var itemLabelIconImageView: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var useButtonOutlet: UIButton!
    @IBOutlet var helpButtonOutlet: UIButton!
    @IBOutlet var cancelButtonOutlet: UIButton!
    @IBOutlet var itemShopButtonIconTextOutlet: UIButton!
    @IBOutlet var activeItemImageView: UIImageView!
    @IBOutlet var activeItemImageView2: UIImageView!
    @IBOutlet var activeItemImageView3: UIImageView!
    @IBOutlet var fundsLabel: UILabel!
    
    
    //Power-Up vars.  ENUM - 0 is none, 1 is mine, 2 is super mine, 3 is bomb, 4 is super bomb, 5 is invuln, 6 is tag reach, 7 is super scan, 8 is lightning, 9 is spy-bot, 10 is jammer, 11 is radar, 12 is ghost (like mario kart), 13 is extra life (power up without returning to base), 14 is team heal (power up all tagged members on team), 15 is reaper (tag closest opponent)
    
    var startingFunds = 0
    var itemAbundance = 0
    
    //powerup currently being displayed
    var activePowerup = 0
    
    //indicate whether offense won game, if so, indicate player
    var gameWinner = "n"
    
    //slot for the currently displayed power up
    var activePowerupSlot = 0
    
    var firstDropped = 0
    var secondDropped = 0
    var thirdDropped = 0
    var fourthDropped = 0
    
    var powerupState = 0
    
    var itemViewHidden = true

    var offense1Inbox = []
    var offense2Inbox = []
    var offense3Inbox = []
    var offense4Inbox = []
    var offense5Inbox = []
    var offenseInbox = []
    var offenseInbox2 = []
    var offenseInbox3 = []
    var offenseInbox4 = []
    var DI = [Double]()
    var DI1 = []
    var DI2 = []
    var DI3 = []
    var DI4 = []
    var DI5 = []
    var defense1Inbox = []
    var defense2Inbox = []
    var defense3Inbox = []
    var defense4Inbox = []
    var defense5Inbox = []
    var defenseInbox = []
    var defenseInbox2 = []
    var defenseInbox3 = []
    var defenseInbox4 = []
    var OI = [Double]()
    var OI1 = []
    var OI2 = []
    var OI3 = []
    var OI4 = []
    var OI5 = []
    
    var OS = []
    var DS = []
    var OS2 = []
    var DS2 = []
    var OM = []
    var DM = []
    var OM2 = []
    var DM2 = []
    var OMU = []
    var DMU = []
    var OMU2 = []
    var DMU2 = []
    
    var I1: Double = 0
    var I2: Double = 0
    var I3: Double = 0
    var I4: Double = 0
    var I5: Double = 0
    
    var drop1DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop1Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop1Circle = MKCircle()
    var drop1Region = CLCircularRegion()
    var drop1Dropped = false
    
    var drop2DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop2Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop2Circle = MKCircle()
    var drop2Region = CLCircularRegion()
    var drop2Dropped = false
    
    var drop3DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop3Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop3Circle = MKCircle()
    var drop3Region = CLCircularRegion()
    var drop3Dropped = false
    
    var drop4DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop4Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop4Circle = MKCircle()
    var drop4Region = CLCircularRegion()
    var drop4Dropped = false
    
    var drop5DropPin = CustomPinDrop(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Item")
    var drop5Coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var drop5Circle = MKCircle()
    var drop5Region = CLCircularRegion()
    var drop5Dropped = false
    
    var all5Dropped = false
    
    var scanCount = 0
    var regScanCount = 0
    var lightningScanCount = 0
    var scanRegion = CLCircularRegion()
    var scanCircle = MKCircle()
    var scanCoordinates = CLLocationCoordinate2D()
    var scanDropPin = CustomPinScan(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Scan")
    
    var mine1Dropped = false
    var mine1isSuper = false
    var mine1Circle = MKCircle()
    var mine1Coordinates = CLLocationCoordinate2D()
    var mine1DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine1DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine1region = CLCircularRegion()
    var mine1Nonce = 0
    
    var mine2Dropped = false
    var mine2isSuper = false
    var mine2Circle = MKCircle()
    var mine2Coordinates = CLLocationCoordinate2D()
    var mine2DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine2DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine2region = CLCircularRegion()
    var mine2Nonce = 0
    
    var mine3Dropped = false
    var mine3isSuper = false
    var mine3Circle = MKCircle()
    var mine3Coordinates = CLLocationCoordinate2D()
    var mine3DropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine3DropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    var mine3region = CLCircularRegion()
    var mine3Nonce = 0
    
    var firstMineDropped = 0
    var secondMineDropped = 0
    
    //nonce for receiving/getting tagged by opponents' mines and bombs
    var mineTagNonce: Int = 0
    var bombTagNonce: Int = 0
    
    //nonces for revealing mines to teammates (view only)
    var mineNonce1: Int = 0
    var mineNonce2: Int = 0
    var mineNonce3: Int = 0
    var mineNonce1B: Int = 0
    var mineNonce2B: Int = 0
    var mineNonce3B: Int = 0
    
    var mine1VDropped = false
    var mine1VNonce = 0
    var mine1VisSuper = false
    var mine1VCircle = MKCircle()
    var mine1VCoordinates = CLLocationCoordinate2D()
    var mine1VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine1VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine2VDropped = false
    var mine2VNonce = 0
    var mine2VisSuper = false
    var mine2VCircle = MKCircle()
    var mine2VCoordinates = CLLocationCoordinate2D()
    var mine2VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine2VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine3VDropped = false
    var mine3VNonce = 0
    var mine3VisSuper = false
    var mine3VCircle = MKCircle()
    var mine3VCoordinates = CLLocationCoordinate2D()
    var mine3VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine3VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine4VDropped = false
    var mine4VNonce = 0
    var mine4VisSuper = false
    var mine4VCircle = MKCircle()
    var mine4VCoordinates = CLLocationCoordinate2D()
    var mine4VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine4VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var mine5VDropped = false
    var mine5VNonce = 0
    var mine5VisSuper = false
    var mine5VCircle = MKCircle()
    var mine5VCoordinates = CLLocationCoordinate2D()
    var mine5VDropPin = CustomPinMine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Mine")
    var supermine5VDropPin = CustomPinSupermine(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Supermine")
    
    var firstMineVDropped = 0
    var secondMineVDropped = 0
    var thirdMineVDropped = 0
    var fourthMineVDropped = 0
    
    var bombCircle = MKCircle()
    var bombDropPin = CustomPinBomb(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Bomb")
    var superbombDropPin = CustomPinSuperbomb(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Bomb")
    var bombRegion = CLCircularRegion()
    
    var jammerCount = 0
    var jammerNonce = 0
    var jammerTeammateNonce = 0
    var ownJammerCount = 0
    
    var spybot1Count = 0
    var spybot1Circle = MKCircle()
    var spybot1Coordinates = CLLocationCoordinate2D()
    var spybot1DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Spybot")
    var spybot1Region = CLCircularRegion()
    var spybot1Dropped = false
    
    var spybot2Count = 0
    var spybot2Circle = MKCircle()
    var spybot2Coordinates = CLLocationCoordinate2D()
    var spybot2DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Spybot")
    var spybot2Region = CLCircularRegion()
    var spybot2Dropped = false
    
    var spybot3Count = 0
    var spybot3Circle = MKCircle()
    var spybot3Coordinates = CLLocationCoordinate2D()
    var spybot3DropPin = CustomPinSpybot(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "Spybot")
    var spybot3Region = CLCircularRegion()
    var spybot3Dropped = false
    
    var firstSpybotDropped = 0
    var secondSpybotDropped = 0
    var spybotNonce1: Int = 0
    var spybotNonce2: Int = 0
    var spybotNonce1B: Int = 0
    var spybotNonce2B: Int = 0
    
    var healNotNonce = 0
    
    var superhealNotNonce = 0
    var superhealNonce = 0
    
    var shieldLevel = 0
    
    var ghostNonce = 0
    var ownGhostCount = 0
    var ghostTeammateNonce = 0
    
    var reachNonce = 0
    var reachCount = 0
    var ownReachCount = 0
    var reachPlayer = 0
    
    var senseCount = 0
    
    var sickleNonce = 0
    
    var lightningNonce = 0
    
    
    //item timer
    var itemTimer = NSTimer()
    var itemTimerCount: Int = 7
    
    //beacon emitter variables
    var peripheralManager = CBPeripheralManager()
    var advertisedData = NSDictionary()
    var emitterRegion = CLBeaconRegion!()
    
    //beacon detector variables
    var detectionRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    //game info data
    var localPlayerMinorValue: UInt16 = 5766
    
    //team localPlayerTeam, 0 = offense, 1 = defense
    var localPlayerTeam: Int = 0
    
    //geofence stuff
    var pointLat: Double = 0
    var pointLong: Double = 0
    var pointRadius = CLLocationDistance(10)
    var baseLat: Double = 0
    var baseLong: Double = 0
    var baseRadius = CLLocationDistance(10)
    var pointCoordinates = CLLocationCoordinate2D()
    var pointRegion = CLCircularRegion()
    var baseCoordinates = CLLocationCoordinate2D()
    var baseRegion = CLCircularRegion()
    var basePointDistance = CLLocationDistance()
    var mapCenterPoint = CLLocationCoordinate2D()
    var mapCenterPointLat: Double = 0
    var mapCenterPointLong: Double = 0
    
    //game options
    var tagThreshold: Int = 0
    var gameLength: Int = 1000
    var captureTime: Int = 10
    var captureClearMapCycleCount = 0
    var timerSyncValue = -1
    var timerSyncValueLast = -1
    var secondsSyncInt = 0
    var powerupsOn = true
    var geoModeOn = true
    
    //game timer
    var gameTimer = NSTimer()
    var captureTimer = NSTimer()
    var captureTimerCount: Int = 10
    var eventsLabelResetCount: Int = 0
    var eventsLabelLast = "n"
    var eventsLabelCurrent = "n"
    
    var networkFailedCount = 0
    
    //offense timers
    var offenseSystemTimer = NSTimer()
    var offenseSystemTimerCount: Int = 5
    
    //defense timers
    var defenseSystemTimer = NSTimer()
    var defenseSystemTimerCount: Int = 5
    
    //defense recharge timer
    var defenseRechargeTimer = NSTimer()
    var defenseRechargeTimerCount: Int = 10
    
    //error/anomaly correction cycle timer
    var errorCorrectionSystemTimer = NSTimer()
    var errorCorrectionSystemTimerCount: Int = 10
    var errorCorrectionSystemTimerReset = true
    
    //timer sync timer
    var timerSyncSystemTimer = NSTimer()
    var timerSyncSystemTimerCount: Int = 15
    
    //overlay clear timer
    var overlayTimer = NSTimer()
    var overlayTimerCount: Int = 0
    
    //tag timer
    var tagTimer = NSTimer()
    var tagTimerCount: Int = 0
    
    
    //dict to assign beacon minor value based on defense position
    let beaconMinorValueDictionary: [String: UInt16] = ["offense1":5761,"offense2":5762,"offense3":5763,"offense4":5764,"offense5":5765,"defense1":5766,"defense2":5767,"defense3":5768,"defense4":5769,"defense5":5760]
    
    var currentRSSI1: Int = -100
    var currentRSSI2: Int = -100

    //sounds
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sounds
        if let logicGamestart2 = self.setupAudioPlayerWithFile("logicGamestart2", type:"mp3") {
            self.logicGamestart2 = logicGamestart2
        }
        self.logicGamestart2?.volume = 0.8
        if let logicPowerUp = self.setupAudioPlayerWithFile("logicPowerUp", type:"mp3") {
            self.logicPowerUp = logicPowerUp
        }
        self.logicPowerUp?.volume = 0.8
        if let logicScan = self.setupAudioPlayerWithFile("logicScan", type:"mp3") {
            self.logicScan = logicScan
        }
        self.logicScan?.volume = 0.8
        if let logicLoseLife = self.setupAudioPlayerWithFile("logicLoseLife", type:"mp3") {
            self.logicLoseLife = logicLoseLife
        }
        self.logicLoseLife?.volume = 0.8
        if let logicCapture = self.setupAudioPlayerWithFile("logicCapture", type:"mp3") {
            self.logicCapture = logicCapture
        }
        self.logicCapture?.volume = 0.8
        if let logicCapturing2 = self.setupAudioPlayerWithFile("logicCapturing2", type:"mp3") {
            self.logicCapturing2 = logicCapturing2
        }
        self.logicCapturing2?.volume = 0.8
        if let logicCancel = self.setupAudioPlayerWithFile("logicCancel", type:"mp3") {
            self.logicCancel = logicCancel
        }
        self.logicCancel?.volume = 0.8
        if let logicReign = self.setupAudioPlayerWithFile("logicReign", type:"mp3") {
            self.logicReign = logicReign
        }
        self.logicReign?.volume = 0.8
        if let logicSFX1 = self.setupAudioPlayerWithFile("logicSFX1", type:"mp3") {
            self.logicSFX1 = logicSFX1
        }
        self.logicSFX1?.volume = 0.8
        if let logicSFX3 = self.setupAudioPlayerWithFile("logicSFX3", type:"mp3") {
            self.logicSFX3 = logicSFX3
        }
        self.logicSFX3?.volume = 0.8
        if let logicSFX4 = self.setupAudioPlayerWithFile("logicSFX4", type:"mp3") {
            self.logicSFX4 = logicSFX4
        }
        self.logicSFX4?.volume = 0.8
        if let logicGotTag = self.setupAudioPlayerWithFile("logicGotTag", type:"mp3") {
            self.logicGotTag = logicGotTag
        }
        self.logicGotTag?.volume = 0.8
        if let backsound = self.setupAudioPlayerWithFile("backsound", type:"mp3") {
            self.backsound = backsound
        }
            self.backsound?.volume = 0.8
        if let bomb = self.setupAudioPlayerWithFile("bomb", type:"mp3") {
            self.bomb = bomb
        }
        self.bomb?.volume = 0.8
        if let chaching = self.setupAudioPlayerWithFile("chaching", type:"mp3") {
            self.chaching = chaching
        }
        self.chaching?.volume = 0.8
        if let coin = self.setupAudioPlayerWithFile("coin", type:"mp3") {
            self.coin = coin
        }
            self.coin?.volume = 0.8
        if let directitem = self.setupAudioPlayerWithFile("directitem", type:"mp3") {
            self.directitem = directitem
        }
            self.directitem?.volume = 0.8
        if let entersound = self.setupAudioPlayerWithFile("entersound", type:"mp3") {
            self.entersound = entersound
        }
            self.entersound?.volume = 0.8
        if let entersoundlow = self.setupAudioPlayerWithFile("entersoundlow", type:"mp3") {
            self.entersoundlow = entersoundlow
        }
            self.entersoundlow?.volume = 0.8
        if let ghost = self.setupAudioPlayerWithFile("ghost", type:"mp3") {
            self.ghost = ghost
        }
            self.ghost?.volume = 0.8
        if let itemdrop = self.setupAudioPlayerWithFile("itemdrop", type:"mp3") {
            self.itemdrop = itemdrop
        }
            self.itemdrop?.volume = 0.6
        if let jammer = self.setupAudioPlayerWithFile("jammer", type:"mp3") {
            self.jammer = jammer
        }
            self.jammer?.volume = 0.8
        if let lightning = self.setupAudioPlayerWithFile("lightning", type:"mp3") {
            self.lightning = lightning
        }
            self.lightning?.volume = 0.8
        if let reach = self.setupAudioPlayerWithFile("reach", type:"mp3") {
            self.reach = reach
        }
            self.reach?.volume = 0.8
        if let scansound = self.setupAudioPlayerWithFile("scansound", type:"mp3") {
            self.scansound = scansound
        }
            self.scansound?.volume = 0.8
        if let setmine = self.setupAudioPlayerWithFile("setmine", type:"mp3") {
            self.setmine = setmine
        }
            self.setmine?.volume = 0.8
        if let shield = self.setupAudioPlayerWithFile("shield", type:"mp3") {
            self.shield = shield
        }
            self.shield?.volume = 0.8
        if let showtargetimageview = self.setupAudioPlayerWithFile("showtargetimageview", type:"mp3") {
            self.showtargetimageview = showtargetimageview
        }
            self.showtargetimageview?.volume = 0.8
        if let sickle = self.setupAudioPlayerWithFile("sickle", type:"mp3") {
            self.sickle = sickle
        }
            self.sickle?.volume = 0.8
        if let spybotsound = self.setupAudioPlayerWithFile("spybotsound", type:"mp3") {
            self.spybotsound = spybotsound
        }
            self.spybotsound?.volume = 0.8
        if let superbomb = self.setupAudioPlayerWithFile("superbomb", type:"mp3") {
            self.superbomb = superbomb
        }
            self.superbomb?.volume = 0.8
        if let bombtag = self.setupAudioPlayerWithFile("bombtag", type:"mp3") {
            self.bombtag = bombtag
        }
            self.bombtag?.volume = 0.8
        if let superbombtag = self.setupAudioPlayerWithFile("superbombtag", type:"mp3") {
            self.superbombtag = superbombtag
        }
            self.superbombtag?.volume = 0.8
        if let sickletag = self.setupAudioPlayerWithFile("sickletag", type:"mp3") {
            self.sickletag = sickletag
        }
            self.sickletag?.volume = 0.8
        if let lightningtag = self.setupAudioPlayerWithFile("lightningtag", type:"mp3") {
            self.lightningtag = lightningtag
        }
            self.lightningtag?.volume = 0.8
        
        
        //background colors
        if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
        }
        
        if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
        }
        
        //hide UI elements
        self.flagImageView.hidden = true
        self.targetImageView.hidden = true
        self.itemButtonBackdropImageView.hidden = true
        self.itemLabelIconImageView.hidden = true
        self.itemLabel.hidden = true
        self.useButtonOutlet.hidden = true
        self.helpButtonOutlet.hidden = true
        self.cancelButtonOutlet.hidden = true
        self.activeItemImageView.hidden = true
        self.activeItemImageView2.hidden = true
        self.activeItemImageView3.hidden = true
        
        //intro sound
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.logicGamestart2?.play()
        
        //set up map & geofence monitoring
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        if globalIsOffense == false { mapView.tintColor = UIColor.redColor() }
        self.mapView.delegate = self
        //self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false)
        self.mapView.mapType = MKMapType.HybridFlyover
        
        locationManager.delegate = self
        self.lifeMeterImageView.hidden = true
        
        globalDefenseWonGame = false
       
        //query game data upon load
        let query = PFQuery(className:"gameInfo")
        query.getObjectInBackgroundWithId(gameInfoObjectID) {
            (gameInfo: PFObject?, error: NSError?) -> Void in
            if error == nil && gameInfo != nil {
                
                offense1var = gameInfo?.objectForKey("offense1") as! String
                offense2var = gameInfo?.objectForKey("offense2") as! String
                offense3var = gameInfo?.objectForKey("offense3") as! String
                offense4var = gameInfo?.objectForKey("offense4") as! String
                offense5var = gameInfo?.objectForKey("offense5") as! String
                
                defense1var = gameInfo?.objectForKey("defense1") as! String
                defense2var = gameInfo?.objectForKey("defense2") as! String
                defense3var = gameInfo?.objectForKey("defense3") as! String
                defense4var = gameInfo?.objectForKey("defense4") as! String
                defense5var = gameInfo?.objectForKey("defense5") as! String
                
                self.tagThreshold = gameInfo?.objectForKey("tagThreshold") as! Int
                self.pointLat = gameInfo?.objectForKey("pointLat") as! Double
                self.pointLong = gameInfo?.objectForKey("pointLong") as! Double
                self.pointRadius = gameInfo?.objectForKey("pointRadius") as! Double
                self.baseLat = gameInfo?.objectForKey("baseLat") as! Double
                self.baseLong = gameInfo?.objectForKey("baseLong") as! Double
                self.baseRadius = gameInfo?.objectForKey("baseRadius") as! Double
                self.gameLength = gameInfo?.objectForKey("gameLength") as! Int
                self.captureTime = gameInfo?.objectForKey("captureTime") as! Int
                self.powerupsOn = gameInfo?.objectForKey("powerupsOn") as! Bool
                testFeaturesOn = gameInfo?.objectForKey("testFeaturesOn") as! Bool
                gameTimerCount = self.gameLength
                
                if self.powerupsOn == true {
                    
                    //calculate vars for geo item drops
                    self.basePointDistance = ((Double(CLLocation(latitude: self.baseLat, longitude: self.baseLong).distanceFromLocation(CLLocation(latitude: self.pointLat, longitude: self.pointLong)) + self.pointRadius ))) / 220000
                    
                    self.mapCenterPointLat = Double((self.pointLat + self.baseLat) / 2)
                    self.mapCenterPointLong = Double((self.pointLong + self.baseLong) / 2)
                    self.mapCenterPoint = CLLocationCoordinate2D(latitude: self.mapCenterPointLat, longitude: self.mapCenterPointLong)
                    
                    //start item timer
                    self.itemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("itemTimerUpdate"), userInfo: nil, repeats: true)
                    self.itemTimer.tolerance = 0.3
                    
                    self.geoModeOn = gameInfo?.objectForKey("itemModeOn") as! Bool
                    
                    if globalIsOffense  == true {
                        let itemPricesTemp = gameInfo?.objectForKey("itemPricesOffense") as! [AnyObject]
                        itemPrices.removeAll()
                        for item in itemPricesTemp {
                            let itemString = "\(item)"
                            let itemInt = Int(itemString)!
                            itemPrices.append(itemInt)
                        }
                        itemsDisabled = gameInfo?.objectForKey("itemsDisabledOffense") as! NSArray
                        self.startingFunds = gameInfo?.objectForKey("offenseStartingFunds") as! Int
                        self.itemAbundance = gameInfo?.objectForKey("itemAbundanceOffense") as! Int
                        currentFunds = self.startingFunds
                    }
                    else {
                        let itemPricesTemp = gameInfo?.objectForKey("itemPricesDefense") as! [AnyObject]
                        for item in itemPricesTemp {
                            let itemString = "\(item)"
                            let itemInt = Int(itemString)!
                            itemPrices.append(itemInt)
                        }
                        itemsDisabled = gameInfo?.objectForKey("itemsDisabledDefense") as! NSArray
                        self.startingFunds = gameInfo?.objectForKey("defenseStartingFunds") as! Int
                        self.itemAbundance = gameInfo?.objectForKey("itemAbundanceDefense") as! Int
                        currentFunds = self.startingFunds
                    }

                    self.fundsLabel.text = "\(currentFunds)"
                    
                }
                else {
                    self.powerup1ButtonOutlet.enabled = false
                    self.powerup2ButtonOutlet.enabled = false
                    self.powerup3ButtonOutlet.enabled = false
                    self.itemShopButtonIconTextOutlet.enabled = false
                    self.powerup1ButtonOutlet.hidden = true
                    self.powerup2ButtonOutlet.hidden = true
                    self.powerup3ButtonOutlet.hidden = true
                    self.itemShopButtonIconTextOutlet.hidden = true
                    self.fundsLabel.hidden = true
                    
                }
                
                //determine the local player's position
                if globalUserName == offense1var {
                    localPlayerPosition = "offense1"
                }
                else if globalUserName == offense2var {
                    localPlayerPosition = "offense2"
                }
                else if globalUserName == offense3var {
                    localPlayerPosition = "offense3"
                }
                else if globalUserName == offense4var {
                    localPlayerPosition = "offense4"
                }
                else if globalUserName == offense5var {
                    localPlayerPosition = "offense5"
                }
                else if globalUserName == defense1var {
                    localPlayerPosition = "defense1"
                }
                else if globalUserName == defense2var {
                    localPlayerPosition = "defense2"
                }
                else if globalUserName == defense3var {
                    localPlayerPosition = "defense3"
                }
                else if globalUserName == defense4var {
                    localPlayerPosition = "defense4"
                }
                else if globalUserName == defense5var {
                    localPlayerPosition = "defense5"
                }

                //populate UI labels
                if testFeaturesOn == true {
                    testViewHidden = false
                    self.thresholdLabel.text = "Thrs: \(self.tagThreshold)" }
                
                //if selected, hide test features
                if testFeaturesOn == false {
                    self.hideTestView(true)
                }
                
                //determine the local player's minor value to broadcast
                if localPlayerPosition != "" {
                self.localPlayerMinorValue = self.beaconMinorValueDictionary[localPlayerPosition]!
                }
                
                //use point/base lat/long to set up CLLocationCoordinate2D for point and base locations
                self.pointCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.pointLat), longitude: CLLocationDegrees(self.pointLong))
                self.baseCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.baseLat), longitude: CLLocationDegrees(self.baseLong))
                
   
                //Add point annotation pin to map view
                self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
                self.mapView.addAnnotation(self.pointDropPin)
                
                //set up circle overlay on point region
                self.pointCircle = MKCircle(centerCoordinate: self.pointCoordinates, radius: self.pointRadius)
                self.mapView?.addOverlay(self.pointCircle)
                
                //Add base pin annotation pin to map view
                self.baseDropPin = CustomPinBase(coordinate: self.baseCoordinates, title: "Offense's base")
                self.mapView.addAnnotation(self.baseDropPin)
                
                //set up circle overlay on base region
                self.baseCircle = MKCircle(centerCoordinate: self.baseCoordinates, radius: self.baseRadius)
                self.mapView?.addOverlay(self.baseCircle)
                
                //if on offense, listen for beacons
                if globalIsOffense == true {
                self.locationManager.startRangingBeaconsInRegion(self.detectionRegion)
                }
         
            
            //start game timer
            self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("gameTimerUpdate"), userInfo: nil, repeats: true)
                //self.gameTimer.tolerance = 0.2
                
                
            //start error/anomaly correction timer
                self.errorCorrectionSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("errorCorrectionSystemTimerUpdate"), userInfo: nil, repeats: true)
                self.errorCorrectionSystemTimer.tolerance = 0.3
                
              
            //start game timer sync timer
//                    self.timerSyncSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerSyncSystemTimerUpdate"), userInfo: nil, repeats: true)
//                    self.timerSyncSystemTimer.tolerance = 0.3
                
            //start offense system timer
                if globalIsOffense == true {
            self.offenseSystemTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("offenseSystemTimerUpdate"), userInfo: nil, repeats: true)
            self.offenseSystemTimer.tolerance = 0.3
                }
            
            //start defense system timer and set alert icon
                if globalIsOffense == false {
            self.defenseSystemTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("defenseSystemTimerUpdate"), userInfo: nil, repeats: true)
            self.defenseSystemTimer.tolerance = 0.3
                }
            
        //set up point/base regions
                self.pointRegion = CLCircularRegion(center: self.pointCoordinates, radius: self.pointRadius, identifier: "pointRegion")
                self.baseRegion = CLCircularRegion(center: self.baseCoordinates, radius: self.baseRadius, identifier: "baseRegion")
        }
            else {
            print("parse inital load game error")
            self.eventsLabel.text = "Loading..."
                query.getObjectInBackgroundWithId(gameInfoObjectID) {
                    (gameInfo: PFObject?, error: NSError?) -> Void in
                    if error == nil && gameInfo != nil {
                        
                        offense1var = gameInfo?.objectForKey("offense1") as! String
                        offense2var = gameInfo?.objectForKey("offense2") as! String
                        offense3var = gameInfo?.objectForKey("offense3") as! String
                        offense4var = gameInfo?.objectForKey("offense4") as! String
                        offense5var = gameInfo?.objectForKey("offense5") as! String
                        
                        defense1var = gameInfo?.objectForKey("defense1") as! String
                        defense2var = gameInfo?.objectForKey("defense2") as! String
                        defense3var = gameInfo?.objectForKey("defense3") as! String
                        defense4var = gameInfo?.objectForKey("defense4") as! String
                        defense5var = gameInfo?.objectForKey("defense5") as! String
                        
                        self.tagThreshold = gameInfo?.objectForKey("tagThreshold") as! Int
                        self.pointLat = gameInfo?.objectForKey("pointLat") as! Double
                        self.pointLong = gameInfo?.objectForKey("pointLong") as! Double
                        self.pointRadius = gameInfo?.objectForKey("pointRadius") as! Double
                        self.baseLat = gameInfo?.objectForKey("baseLat") as! Double
                        self.baseLong = gameInfo?.objectForKey("baseLong") as! Double
                        self.baseRadius = gameInfo?.objectForKey("baseRadius") as! Double
                        self.gameLength = gameInfo?.objectForKey("gameLength") as! Int
                        self.captureTime = gameInfo?.objectForKey("captureTime") as! Int
                        self.powerupsOn = gameInfo?.objectForKey("powerupsOn") as! Bool
                        testFeaturesOn = gameInfo?.objectForKey("testFeaturesOn") as! Bool
                        gameTimerCount = self.gameLength
                        
                        if self.powerupsOn == true {
                            
                            //calculate vars for geo item drops
                            self.basePointDistance = ((Double(CLLocation(latitude: self.baseLat, longitude: self.baseLong).distanceFromLocation(CLLocation(latitude: self.pointLat, longitude: self.pointLong)) + self.pointRadius ))) / 220000
                            
                            self.mapCenterPointLat = Double((self.pointLat + self.baseLat) / 2)
                            self.mapCenterPointLong = Double((self.pointLong + self.baseLong) / 2)
                            self.mapCenterPoint = CLLocationCoordinate2D(latitude: self.mapCenterPointLat, longitude: CLLocationDegrees(((self.pointLong + self.baseLong) / 2)))
                            
                            //start item timer
                            self.itemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("itemTimerUpdate"), userInfo: nil, repeats: true)
                            self.itemTimer.tolerance = 0.3
                            
                            self.geoModeOn = gameInfo?.objectForKey("itemModeOn") as! Bool
                            
                            if globalIsOffense  == true {
                                let itemPricesTemp = gameInfo?.objectForKey("itemPricesOffense") as! [AnyObject]
                                itemPrices.removeAll()
                                for item in itemPricesTemp {
                                    let itemString = "\(item)"
                                    let itemInt = Int(itemString)!
                                    itemPrices.append(itemInt)
                                }
                                itemsDisabled = gameInfo?.objectForKey("itemsDisabledOffense") as! NSArray
                                self.startingFunds = gameInfo?.objectForKey("offenseStartingFunds") as! Int
                                self.itemAbundance = gameInfo?.objectForKey("itemAbundanceOffense") as! Int
                                currentFunds = self.startingFunds
                            }
                            else {
                                let itemPricesTemp = gameInfo?.objectForKey("itemPricesDefense") as! [AnyObject]
                                for item in itemPricesTemp {
                                    let itemString = "\(item)"
                                    let itemInt = Int(itemString)!
                                    itemPrices.append(itemInt)
                                }
                                itemsDisabled = gameInfo?.objectForKey("itemsDisabledDefense") as! NSArray
                                self.startingFunds = gameInfo?.objectForKey("defenseStartingFunds") as! Int
                                self.itemAbundance = gameInfo?.objectForKey("itemAbundanceDefense") as! Int
                                currentFunds = self.startingFunds
                            }
    
                            self.fundsLabel.text = "\(currentFunds)"
                            
                        }
                        else {
                            self.powerup1ButtonOutlet.enabled = false
                            self.powerup2ButtonOutlet.enabled = false
                            self.powerup3ButtonOutlet.enabled = false
                            self.itemShopButtonIconTextOutlet.enabled = false
                            self.powerup1ButtonOutlet.hidden = true
                            self.powerup2ButtonOutlet.hidden = true
                            self.powerup3ButtonOutlet.hidden = true
                            self.itemShopButtonIconTextOutlet.hidden = true
                            self.fundsLabel.hidden = true
                        }
                        
                        //determine the local player's position
                        if globalUserName == offense1var {
                            localPlayerPosition = "offense1"
                        }
                        else if globalUserName == offense2var {
                            localPlayerPosition = "offense2"
                        }
                        else if globalUserName == offense3var {
                            localPlayerPosition = "offense3"
                        }
                        else if globalUserName == offense4var {
                            localPlayerPosition = "offense4"
                        }
                        else if globalUserName == offense5var {
                            localPlayerPosition = "offense5"
                        }
                        else if globalUserName == defense1var {
                            localPlayerPosition = "defense1"
                        }
                        else if globalUserName == defense2var {
                            localPlayerPosition = "defense2"
                        }
                        else if globalUserName == defense3var {
                            localPlayerPosition = "defense3"
                        }
                        else if globalUserName == defense4var {
                            localPlayerPosition = "defense4"
                        }
                        else if globalUserName == defense5var {
                            localPlayerPosition = "defense5"
                        }
                        
                        //populate UI labels
                        if testFeaturesOn == true {
                            self.thresholdLabel.text = "Thrs: \(self.tagThreshold)" }
                        
                        //if selected, hide test features
                        if testFeaturesOn == false {
                            self.thresholdLabel.hidden = true
                            self.RSSILabel.hidden = true
                            self.testButton.hidden = true
                            self.testButton2Outlet.hidden = true
                        }
                        
                        //determine the local player's minor value to broadcast
                        if localPlayerPosition != "" {
                            self.localPlayerMinorValue = self.beaconMinorValueDictionary[localPlayerPosition]!
                        }
                        
                        //use point/base lat/long to set up CLLocationCoordinate2D for point and base locations
                        self.pointCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.pointLat), longitude: CLLocationDegrees(self.pointLong))
                        self.baseCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.baseLat), longitude: CLLocationDegrees(self.baseLong))
                        
                        //Add point annotation pin to map view
                        self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
                        self.mapView.addAnnotation(self.pointDropPin)
                        
                        //set up circle overlay on point region
                        self.pointCircle = MKCircle(centerCoordinate: self.pointCoordinates, radius: self.pointRadius)
                        self.mapView?.addOverlay(self.pointCircle)
                        
                        //set up circle overlay on base region
                        self.baseCircle = MKCircle(centerCoordinate: self.baseCoordinates, radius: self.baseRadius)
                        self.mapView?.addOverlay(self.baseCircle)
                        
                        //if on offense, listen for beacons
                        if globalIsOffense == true {
                            self.locationManager.startRangingBeaconsInRegion(self.detectionRegion)
                        }
                        
                        
                        //start game timer
                        self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("gameTimerUpdate"), userInfo: nil, repeats: true)
                        self.gameTimer.tolerance = 0.2
                        
                        
                        //start error/anomaly correction timer
                            self.errorCorrectionSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("errorCorrectionSystemTimerUpdate"), userInfo: nil, repeats: true)
                            self.errorCorrectionSystemTimer.tolerance = 0.3
            
                        
                        //start game timer sync timer
                            self.timerSyncSystemTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerSyncSystemTimerUpdate"), userInfo: nil, repeats: true)
                            self.timerSyncSystemTimer.tolerance = 0.3
                        
                        //start offense system timer
                        if globalIsOffense == true {
                            self.offenseSystemTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("offenseSystemTimerUpdate"), userInfo: nil, repeats: true)
                            self.offenseSystemTimer.tolerance = 0.3
                        }
                        
                        //start defense system timer and set alert icon
                        if globalIsOffense == false {
                            self.defenseSystemTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("defenseSystemTimerUpdate"), userInfo: nil, repeats: true)
                            self.defenseSystemTimer.tolerance = 0.3
                        }
                        
                        //set up point/base regions
                        self.pointRegion = CLCircularRegion(center: self.pointCoordinates, radius: self.pointRadius, identifier: "pointRegion")
                        self.baseRegion = CLCircularRegion(center: self.baseCoordinates, radius: self.baseRadius, identifier: "baseRegion")
                    }
                    
                    else {
                        print("parse inital load game error")
                        self.eventsLabel.text = "Fatal error - reset game"
                        
                    }
                    
                }
                
            }
        
        
    //broadcast beacon signal, if on defense
    if globalIsOffense == false {
        self.emitterRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 5151, minor: self.localPlayerMinorValue, identifier: "Estimotes")
        self.advertisedData = self.emitterRegion.peripheralDataWithMeasuredPower(nil)
            }
        }
    }
    //after inital load (nav to from item shop or menu)
        
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            
            if map3d == true {
                self.mapView.mapType = MKMapType.HybridFlyover
            }
            if map3d == false {
                self.mapView.mapType = MKMapType.Satellite
            }
            
            self.refreshItems()
        
    }
    
//quit game if selected from menu
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if testFeaturesOn == true && testViewHidden == false {
            self.hideTestView(false)
        }
        else if testFeaturesOn == true && testViewHidden == true {
            self.hideTestView(true)
        }
        
        if puhack == true {
            localPlayerStatus = 1
            puhack = false
        }
        
        
        if initialMapSetup2 == false {
            self.initialMapSetup2 = true
        self.mapCamera = MKMapCamera(lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), fromDistance: 400, pitch: 25, heading: 45)
        self.mapView.setCamera(self.mapCamera, animated: false)
        }
        
        if quittingGame == true {
            self.quitGame()
        }
        quittingGame = false
        
        if globalDefenseWonGame == true {
            self.captureTimer.invalidate()
            self.itemTimer.invalidate()
            self.gameTimer.invalidate()
            self.offenseSystemTimer.invalidate()
            self.defenseSystemTimer.invalidate()
            self.defenseRechargeTimer.invalidate()
            self.errorCorrectionSystemTimer.invalidate()
            self.timerSyncSystemTimer.invalidate()
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
            self.locationManager.stopUpdatingLocation()
            self.performSegueWithIdentifier("showGameResultsViewController", sender: nil)
        }
        
        if self.gameWinner != "n" {
            self.captureTimer.invalidate()
            self.itemTimer.invalidate()
            self.gameTimer.invalidate()
            self.offenseSystemTimer.invalidate()
            self.defenseSystemTimer.invalidate()
            self.defenseRechargeTimer.invalidate()
            self.errorCorrectionSystemTimer.invalidate()
            self.timerSyncSystemTimer.invalidate()
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
            self.locationManager.stopUpdatingLocation()
            self.performSegueWithIdentifier("showGameResultsViewController", sender: nil)
            sleep(1)
        }
    }
    
//end of view did load
    
    @IBAction func testButton(sender: AnyObject) {
       
        //power up offense player
        if globalIsOffense == true && (localPlayerStatus == 2 || localPlayerStatus == 0) {
            localPlayerStatus = 1
            
            self.alertIconImageView.hidden = true
            self.iconLabel.hidden = true
            self.lifeMeterImageView.hidden = false
            self.lifeMeterImageView.image = UIImage(named:"5life.png")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
            
        }
        
        //power up defense player 
        if globalIsOffense == false && (localPlayerStatus == 2 || localPlayerStatus == 0) {
            localPlayerStatus = 1
            
            //set the alert icon and label
            if playerCapturedPoint == "n" {
                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                self.iconLabel.text = "Flag in place"
            }
            if playerCapturedPoint != "n" {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
            
            //start broadcasting beacon
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
        }
        
    
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func powerup1Button(sender: AnyObject) {
        
        if slot1Powerup == 0 {
            if globalIsOffense == true {
                self.performSegueWithIdentifier("showOffenseItemShopViewControllerFromGameViewController", sender: nil)
            }
            else {
                self.performSegueWithIdentifier("showDefenseItemShopViewControllerFromGameViewController", sender: nil)
            }
        }
        if slot1Powerup == 1 {
            self.itemLabel.text = "Scan"
            self.itemLabelIconImageView.image = UIImage(named:"scan.png")
            self.activePowerup = 1
            self.showRadarItemView()
        }
        if slot1Powerup == 2 {
            self.itemLabel.text = "Super Scan"
            self.itemLabelIconImageView.image = UIImage(named:"superscan.png")
            self.activePowerup = 2
            self.showItemView()
        }
        if slot1Powerup == 3 {
            self.itemLabel.text = "Mine"
            self.itemLabelIconImageView.image = UIImage(named:"mine40.png")
            self.activePowerup = 3
            self.showTargetItemView()
        }
        if slot1Powerup == 4 {
            self.itemLabel.text = "Super Mine"
            self.itemLabelIconImageView.image = UIImage(named:"supermine.png")
            self.activePowerup = 4
            self.showTargetItemView()
        }
        if slot1Powerup == 5 {
            self.itemLabel.text = "Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"bomb.png")
            self.activePowerup = 5
            self.showTargetItemView()
        }
        if slot1Powerup == 6 {
            self.itemLabel.text = "Super Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"superbomb.png")
            self.activePowerup = 6
            self.showTargetItemView()
        }
        if slot1Powerup == 7 {
            self.itemLabel.text = "Jammer"
            self.itemLabelIconImageView.image = UIImage(named:"jammer.png")
            self.activePowerup = 7
            self.showItemView()
        }
        if slot1Powerup == 8 {
            self.itemLabel.text = "Spybot"
            self.itemLabelIconImageView.image = UIImage(named:"spybot.png")
            self.activePowerup = 8
            self.showSpybotItemView()
        }
        if slot1Powerup == 9 {
            self.itemLabel.text = "Heal"
            self.itemLabelIconImageView.image = UIImage(named:"heal.png")
            self.activePowerup = 9
            self.showItemView()
        }
        if slot1Powerup == 10 {
            self.itemLabel.text = "Super Heal"
            self.itemLabelIconImageView.image = UIImage(named:"superheal.png")
            self.activePowerup = 10
            self.showItemView()
        }
        if slot1Powerup == 11 {
            self.itemLabel.text = "Shield"
            self.itemLabelIconImageView.image = UIImage(named:"shield.png")
            self.activePowerup = 11
            self.showItemView()
        }
        if slot1Powerup == 12 {
            self.itemLabel.text = "Ghost"
            self.itemLabelIconImageView.image = UIImage(named:"ghost.png")
            self.activePowerup = 12
            self.showItemView()
        }
        if slot1Powerup == 13 {
            self.itemLabel.text = "Reach"
            self.itemLabelIconImageView.image = UIImage(named:"reach.png")
            self.activePowerup = 13
            self.showItemView()
        }
        if slot1Powerup == 14 {
            self.itemLabel.text = "Sense"
            self.itemLabelIconImageView.image = UIImage(named:"fist.png")
            self.activePowerup = 14
            self.showItemView()
        }
        if slot1Powerup == 15 {
            self.itemLabel.text = "Sickle"
            self.itemLabelIconImageView.image = UIImage(named:"sickle.png")
            self.activePowerup = 15
            self.showItemView()
        }
        if slot1Powerup == 16 {
            self.itemLabel.text = "Lightning"
            self.itemLabelIconImageView.image = UIImage(named:"lightning.png")
            self.activePowerup = 16
            self.showItemView()
        }
        
        if slot1Powerup != 0 {
            self.activePowerupSlot = 1
        }
        
    }
    
    @IBAction func powerup2Button(sender: AnyObject) {
        
        if slot2Powerup == 0 {
            if globalIsOffense == true {
                self.performSegueWithIdentifier("showOffenseItemShopViewControllerFromGameViewController", sender: nil)
            }
            else {
                self.performSegueWithIdentifier("showDefenseItemShopViewControllerFromGameViewController", sender: nil)
            }
        }
        if slot2Powerup == 1 {
            self.itemLabel.text = "Scan"
            self.itemLabelIconImageView.image = UIImage(named:"scan.png")
            self.activePowerup = 1
            self.showRadarItemView()
        }
        if slot2Powerup == 2 {
            self.itemLabel.text = "Super Scan"
            self.itemLabelIconImageView.image = UIImage(named:"superscan.png")
            self.activePowerup = 2
            self.showItemView()
        }
        if slot2Powerup == 3 {
            self.itemLabel.text = "Mine"
            self.itemLabelIconImageView.image = UIImage(named:"mine40.png")
            self.activePowerup = 3
            self.showTargetItemView()
        }
        if slot2Powerup == 4 {
            self.itemLabel.text = "Super Mine"
            self.itemLabelIconImageView.image = UIImage(named:"supermine.png")
            self.activePowerup = 4
            self.showTargetItemView()
        }
        if slot2Powerup == 5 {
            self.itemLabel.text = "Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"bomb.png")
            self.activePowerup = 5
            self.showTargetItemView()
        }
        if slot2Powerup == 6 {
            self.itemLabel.text = "Super Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"superbomb.png")
            self.activePowerup = 6
            self.showTargetItemView()
        }
        if slot2Powerup == 7 {
            self.itemLabel.text = "Jammer"
            self.itemLabelIconImageView.image = UIImage(named:"jammer.png")
            self.activePowerup = 7
            self.showItemView()
        }
        if slot2Powerup == 8 {
            self.itemLabel.text = "Spybot"
            self.itemLabelIconImageView.image = UIImage(named:"spybot.png")
            self.activePowerup = 8
            self.showSpybotItemView()
        }
        if slot2Powerup == 9 {
            self.itemLabel.text = "Heal"
            self.itemLabelIconImageView.image = UIImage(named:"heal.png")
            self.activePowerup = 9
            self.showItemView()
        }
        if slot2Powerup == 10 {
            self.itemLabel.text = "Super Heal"
            self.itemLabelIconImageView.image = UIImage(named:"superheal.png")
            self.activePowerup = 10
            self.showItemView()
        }
        if slot2Powerup == 11 {
            self.itemLabel.text = "Shield"
            self.itemLabelIconImageView.image = UIImage(named:"shield.png")
            self.activePowerup = 11
            self.showItemView()
        }
        if slot2Powerup == 12 {
            self.itemLabel.text = "Ghost"
            self.itemLabelIconImageView.image = UIImage(named:"ghost.png")
            self.activePowerup = 12
            self.showItemView()
        }
        if slot2Powerup == 13 {
            self.itemLabel.text = "Reach"
            self.itemLabelIconImageView.image = UIImage(named:"reach.png")
            self.activePowerup = 13
            self.showItemView()
        }
        if slot2Powerup == 14 {
            self.itemLabel.text = "Sense"
            self.itemLabelIconImageView.image = UIImage(named:"fist.png")
            self.activePowerup = 14
            self.showItemView()
        }
        if slot2Powerup == 15 {
            self.itemLabel.text = "Sickle"
            self.itemLabelIconImageView.image = UIImage(named:"sickle.png")
            self.activePowerup = 15
            self.showItemView()
        }
        if slot2Powerup == 16 {
            self.itemLabel.text = "Lightning"
            self.itemLabelIconImageView.image = UIImage(named:"lightning.png")
            self.activePowerup = 16
            self.showItemView()
        }
        
        if slot2Powerup != 0 {
            self.activePowerupSlot = 2
        }
        
    }
    
    @IBAction func powerup3Button(sender: AnyObject) {
        
        if slot3Powerup == 0 {
            if globalIsOffense == true {
                self.performSegueWithIdentifier("showOffenseItemShopViewControllerFromGameViewController", sender: nil)
            }
            else {
                self.performSegueWithIdentifier("showDefenseItemShopViewControllerFromGameViewController", sender: nil)
            }
        }
        if slot3Powerup == 1 {
            self.itemLabel.text = "Scan"
            self.itemLabelIconImageView.image = UIImage(named:"scan.png")
            self.activePowerup = 1
            self.showRadarItemView()
        }
        if slot3Powerup == 2 {
            self.itemLabel.text = "Super Scan"
            self.itemLabelIconImageView.image = UIImage(named:"superscan.png")
            self.activePowerup = 2
            self.showItemView()
        }
        if slot3Powerup == 3 {
            self.itemLabel.text = "Mine"
            self.itemLabelIconImageView.image = UIImage(named:"mine40.png")
            self.activePowerup = 3
            self.showTargetItemView()
        }
        if slot3Powerup == 4 {
            self.itemLabel.text = "Super Mine"
            self.itemLabelIconImageView.image = UIImage(named:"supermine.png")
            self.activePowerup = 4
            self.showTargetItemView()
        }
        if slot3Powerup == 5 {
            self.itemLabel.text = "Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"bomb.png")
            self.activePowerup = 5
            self.showTargetItemView()
        }
        if slot3Powerup == 6 {
            self.itemLabel.text = "Super Bomb"
            self.itemLabelIconImageView.image = UIImage(named:"superbomb.png")
            self.activePowerup = 6
            self.showTargetItemView()
        }
        if slot3Powerup == 7 {
            self.itemLabel.text = "Jammer"
            self.itemLabelIconImageView.image = UIImage(named:"jammer.png")
            self.activePowerup = 7
            self.showItemView()
        }
        if slot3Powerup == 8 {
            self.itemLabel.text = "Spybot"
            self.itemLabelIconImageView.image = UIImage(named:"spybot.png")
            self.activePowerup = 8
            self.showSpybotItemView()
        }
        if slot3Powerup == 9 {
            self.itemLabel.text = "Heal"
            self.itemLabelIconImageView.image = UIImage(named:"heal.png")
            self.activePowerup = 9
            self.showItemView()
        }
        if slot3Powerup == 10 {
            self.itemLabel.text = "Super Heal"
            self.itemLabelIconImageView.image = UIImage(named:"superheal.png")
            self.activePowerup = 10
            self.showItemView()
        }
        if slot3Powerup == 11 {
            self.itemLabel.text = "Shield"
            self.itemLabelIconImageView.image = UIImage(named:"shield.png")
            self.activePowerup = 11
            self.showItemView()
        }
        if slot3Powerup == 12 {
            self.itemLabel.text = "Ghost"
            self.itemLabelIconImageView.image = UIImage(named:"ghost.png")
            self.activePowerup = 12
            self.showItemView()
        }
        if slot3Powerup == 13 {
            self.itemLabel.text = "Reach"
            self.itemLabelIconImageView.image = UIImage(named:"reach.png")
            self.activePowerup = 13
            self.showItemView()
        }
        if slot3Powerup == 14 {
            self.itemLabel.text = "Sense"
            self.itemLabelIconImageView.image = UIImage(named:"fist.png")
            self.activePowerup = 14
            self.showItemView()
        }
        if slot3Powerup == 15 {
            self.itemLabel.text = "Sickle"
            self.itemLabelIconImageView.image = UIImage(named:"sickle.png")
            self.activePowerup = 15
            self.showItemView()
        }
        if slot3Powerup == 16 {
            self.itemLabel.text = "Lightning"
            self.itemLabelIconImageView.image = UIImage(named:"lightning.png")
            self.activePowerup = 16
            self.showItemView()
        }
        
        if slot3Powerup != 0 {
            self.activePowerupSlot = 3
        }
        
    }
    
    @IBAction func useButton(sender: AnyObject) {
        mapView.pitchEnabled = true
        mapView.zoomEnabled = true
        
        //scan
        if self.activePowerup == 1 {
        
            self.scansound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            //capture current screen coordinate
            let screenCoordinate = mapView.centerCoordinate
            let scanCoordinate = CLLocationCoordinate2D(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude)
            
            self.scanDropPin.coordinate = screenCoordinate
            self.scanDropPin.title = "scan"
            self.mapView.addAnnotation(self.scanDropPin)
            
            //start overlay timer
            self.overlayTimerCount = 1
            self.overlayTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("overlayTimerUpdate"), userInfo: nil, repeats: true)
            self.overlayTimer.tolerance = 0.3
            
            self.scanRegion = CLCircularRegion(center: screenCoordinate, radius: CLLocationDistance(20), identifier: "scanRegion")
            
            self.regScanCount = 1
            scan(self.scanRegion, circle: self.scanCircle)
            clearAfterUse()
        }
        
        //super scan
        if self.activePowerup == 2 {
            
            self.scanCount = 1
            self.superscan()
        
            self.scansound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

            clearAfterUse()
        }
        
        
        //mine
        if self.activePowerup == 3 || self.activePowerup == 4 {
            var activePowerupTemp = 3
            if self.activePowerup == 4 {
            activePowerupTemp = 4
            }
            
            //capture current screen and player coordinates
            let screenCoordinate = mapView.centerCoordinate
            let mineCoordinate = CLLocationCoordinate2D(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude)
            //BOOKMARK
            let distanceFromPlayer = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude).distanceFromLocation(CLLocation(latitude: screenCoordinate.latitude, longitude: screenCoordinate.longitude))
            if self.baseRegion.containsCoordinate(mineCoordinate) == true || self.pointRegion.containsCoordinate(mineCoordinate) == true {
                displayAlert("Error", message: "You can't plant a mine in the base or flag regions")
                mapView.pitchEnabled = false
                mapView.zoomEnabled = false
            }
//            else if distanceFromPlayer > 20 {
//                displayAlert("Error", message: "Must plant within 20 meters of your current location")
//                mapView.pitchEnabled = false
//                mapView.zoomEnabled = false
//            }
            else if self.mine1Dropped == true && self.mine2Dropped == true && self.mine3Dropped == true {
                
                let refreshAlert = UIAlertController(title: "Mine limit reached", message: "You can't plant more than three mines at once, exchange mine for money?", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    if self.activePowerupSlot == 1 {
                        slot1Powerup = 0
                    }
                    if self.activePowerupSlot == 2 {
                        slot2Powerup = 0
                    }
                    if self.activePowerupSlot == 3 {
                        slot3Powerup = 0
                    }
                    if self.activePowerup == 3 {
                        currentFunds = currentFunds + 5
                    }
                    if self.activePowerup == 4 {
                        currentFunds = currentFunds + 10
                    }
                    self.activePowerup = 0
                    self.clearAfterUse()
                    self.refreshItems()
                    
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
                    self.itemViewHidden = true
                    self.targetImageView.hidden = true
                    self.itemButtonBackdropImageView.hidden = true
                    self.itemLabelIconImageView.hidden = true
                    self.itemLabel.hidden = true
                    self.useButtonOutlet.hidden = true
                    self.helpButtonOutlet.hidden = true
                    self.cancelButtonOutlet.hidden = true
                 
   
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)

            }
            else {
                let nonceTemp = Int(arc4random_uniform(999999))
                
                if self.activePowerup == 3 {
                    self.postMine(screenCoordinate.latitude, long: screenCoordinate.longitude, isSuper: false, nonce: nonceTemp)
                    self.dropMine(screenCoordinate.latitude, long: screenCoordinate.longitude, isSuper: false, nonce: nonceTemp)
                    self.logEvent("Mine planted!")
                }
                if self.activePowerup == 4 {
                    self.postMine(screenCoordinate.latitude, long: screenCoordinate.longitude, isSuper: true, nonce: nonceTemp)
                    self.dropMine(screenCoordinate.latitude, long: screenCoordinate.longitude, isSuper: true, nonce: nonceTemp)
                    self.logEvent("Supermine planted!")
                }
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.setmine?.play()
                clearAfterUse()
            }
        }
        
        //bomb
        if self.activePowerup == 5 || self.activePowerup == 6 {
            
            //capture current screen coordinate
            let screenCoordinate = mapView.centerCoordinate
            
                itemInfo.fetchInBackgroundWithBlock  {
                    (itemInfo: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        self.displayAlert("Error", message: "Network error, try agian")
                    } else if let itemInfo = itemInfo {
                        
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        if self.activePowerup == 5 {
                        self.bomb?.play()
                        self.bombDropPin.coordinate = screenCoordinate
                        self.bombDropPin.title = "bomb"
                        self.mapView.addAnnotation(self.bombDropPin)
                        
                        //start overlay timer
                        self.overlayTimerCount = 1
                        self.overlayTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("overlayTimerUpdate"), userInfo: nil, repeats: true)
                        self.overlayTimer.tolerance = 0.3
                            
                        self.bombRegion = CLCircularRegion(center: screenCoordinate, radius: CLLocationDistance(8), identifier: "bombRegion")
                        //self.bombCircle = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(8))
                        //self.mapView.addOverlay(self.bombCircle)
                        }
                        if self.activePowerup == 6 {
                        self.superbomb?.play()
                        self.superbombDropPin.coordinate = screenCoordinate
                        self.superbombDropPin.title = "superbomb"
                        self.mapView.addAnnotation(self.superbombDropPin)
                        
                        //start overlay timer
                        self.overlayTimerCount = 1
                        self.overlayTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("overlayTimerUpdate"), userInfo: nil, repeats: true)
                        self.overlayTimer.tolerance = 0.3
                            
                        self.bombRegion = CLCircularRegion(center: screenCoordinate, radius: CLLocationDistance(15), identifier: "bombRegion")
                        //self.bombCircle = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(15))
                        //self.mapView.addOverlay(self.bombCircle)
                        }

                            if self.bombRegion.containsCoordinate(self.defense1Coordinates) || self.bombRegion.containsCoordinate(self.defense2Coordinates) || self.bombRegion.containsCoordinate(self.defense3Coordinates) || self.bombRegion.containsCoordinate(self.defense4Coordinates) || self.bombRegion.containsCoordinate(self.defense5Coordinates) || self.bombRegion.containsCoordinate(self.offense1Coordinates) || self.bombRegion.containsCoordinate(self.offense2Coordinates) || self.bombRegion.containsCoordinate(self.offense3Coordinates) || self.bombRegion.containsCoordinate(self.offense4Coordinates) || self.bombRegion.containsCoordinate(self.offense5Coordinates) {
                                
                                var playerTaggedByBomb = ""
                                var playersTaggedByBomb = 0
                                let nonceTempB = Int(arc4random_uniform(999999))
                                
                                if self.bombRegion.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
                                    itemInfo["defense1Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = defense1var
                                    self.revealTagee(defense1var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
                                    itemInfo["defense2Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = defense2var
                                    self.revealTagee(defense2var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
                                    itemInfo["defense3Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = defense3var
                                    self.revealTagee(defense3var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
                                    itemInfo["defense4Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = defense4var
                                    self.revealTagee(defense4var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
                                    itemInfo["defense5Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = defense5var
                                    self.revealTagee(defense5var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
                                    itemInfo["offense1Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = offense1var
                                    self.revealTagee(offense1var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
                                    itemInfo["offense2Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = offense2var
                                    self.revealTagee(offense2var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
                                    itemInfo["offense3Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = offense3var
                                    self.revealTagee(offense3var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
                                    itemInfo["offense4Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = offense4var
                                    self.revealTagee(offense4var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                if self.bombRegion.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
                                    itemInfo["offense5Inbox"] = [5,globalUserName,nonceTempB]
                                    playerTaggedByBomb = offense5var
                                    self.revealTagee(offense5var)
                                    playersTaggedByBomb++
                                    playerTagCount++
                                }
                                
                                if playersTaggedByBomb > 1 {
                                    self.logEvent("Bomb tagged \(playersTaggedByBomb) players!")
                                    itemInfo.saveEventually()
                                }
                                else if playerTaggedByBomb != "" {
                                    self.logEvent("Bomb tagged \(playerTaggedByBomb)!")
                                    itemInfo.saveEventually()
                                }
                                else {
                                    self.logEvent("Bomb missed")
                                }
                                
                            }
                    
                            else { self.logEvent("Bomb missed") }
      
                                    self.clearAfterUse()
                        
                        
                }
            }
        }
        
        //jammer
        if self.activePowerup == 7 {
            
            self.jammer?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            itemInfo.fetchInBackgroundWithBlock  {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try agian")
                } else if let itemInfo = itemInfo {
                    
                    let rand = Int(arc4random_uniform(999999))
                    if globalIsOffense == true {
                    itemInfo["defenseInbox2"] = [7,rand]
                        itemInfo["offenseInbox4"] = [7,rand,globalUserName]
                        
                    }
                    if globalIsOffense == false {
                    itemInfo["offenseInbox2"] = [7,rand]
                        itemInfo["defenseInbox4"] = [7,rand,globalUserName]
                    }
                    self.ownJammerCount = 1
                    self.addActiveItemImageView(7)
                    itemInfo.saveEventually()
                }
                
            }
            clearAfterUse()
        }
        
        //spybot
        if self.activePowerup == 8 {
            let screenCoordinate = mapView.centerCoordinate
            let latTemp: Double = Double(screenCoordinate.latitude)
            let longTemp: Double = Double(screenCoordinate.longitude)
            self.dropSpybot(latTemp, long: longTemp, player: globalUserName)
            self.postSpybot(latTemp, long: longTemp)
            clearAfterUse()
        }
        
    //heal
        if self.activePowerup == 9 {
            self.heal()
            self.logEvent("Healed!")
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try agian")
                } else if let itemInfo = itemInfo {
                    
                    let rand = Int(arc4random_uniform(999999))
                    itemInfo["defenseInbox3"] = [9,rand,globalUserName]
                    itemInfo.saveEventually()
                }
            }
            clearAfterUse()
        }
        
        //superheal
        if self.activePowerup == 10 {
            self.heal()
            self.logEvent("Healed!")
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try agian")
                } else if let itemInfo = itemInfo {
                    
                    let rand = Int(arc4random_uniform(999999))
                    self.superhealNonce = rand
                    itemInfo["offenseInbox"] = [10,rand]
                    itemInfo["defenseInbox3"] = [10,rand]
                    itemInfo.saveEventually()
                }
                
            }
            clearAfterUse()
        }
        
        //shield 
        if self.activePowerup == 11 {
            if localPlayerStatus != 1 {
                 displayAlert("Error", message: "Must power-up before using shield")
            }
            else {
            self.shieldLevel = 6
            self.lifeMeterImageView.image = UIImage(named:"lifeshield.png")
                self.shield?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                clearAfterUse()
            }
        }
        
        //ghost 
        if self.activePowerup == 12 {
            
            self.ghost?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
                itemInfo.fetchInBackgroundWithBlock {
                    (itemInfo: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        self.displayAlert("Error", message: "Network error, try agian")
                    } else if let itemInfo = itemInfo {
                        
                        let rand = Int(arc4random_uniform(999999))
                        itemInfo["defenseInbox"] = [12,rand,0]
                        itemInfo["offenseInbox4"] = [12,rand,globalUserName]
                        self.ownGhostCount = 1
                        self.addActiveItemImageView(12)
                        itemInfo.saveEventually()
                    }
                    
                }
                clearAfterUse()
            
        }
        
        //reach
        if self.activePowerup == 13 {
            self.reach?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try agian")
                } else if let itemInfo = itemInfo {
                    var playerNum = 0
                    if localPlayerPosition == "defense1" {
                        playerNum = 5766 }
                    if localPlayerPosition == "defense2" {
                        playerNum = 5767 }
                    if localPlayerPosition == "defense3" {
                        playerNum = 5768 }
                    if localPlayerPosition == "defense4" {
                        playerNum = 5769 }
                    if localPlayerPosition == "defense5" {
                        playerNum = 5760 }
                    
                    let rand = Int(arc4random_uniform(999999))
                    itemInfo["offenseInbox3"] = [13,rand,playerNum]
                    self.ownReachCount = 1
                    self.addActiveItemImageView(13)
                    itemInfo.saveEventually()
                }
                
            }
            clearAfterUse()
            
        }
        
        //sense
        if self.activePowerup == 14 {
            self.senseCount = 1
            self.logEvent("Sensing...")
            self.addActiveItemImageView(14)
            self.entersound?.play()
            self.scan(CLCircularRegion(center: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), radius: CLLocationDistance(20), identifier: "sense region"), circle: MKCircle())
            clearAfterUse()
        }
        
        //sickle
        if self.activePowerup == 15 {
            self.sickle?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            //determine which opponent is closest
            let currentCoordinate = CLLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
            let distance1 = currentCoordinate.distanceFromLocation(CLLocation(latitude: self.offense1Lat, longitude: self.offense1Long))
            let distance2 = currentCoordinate.distanceFromLocation(CLLocation(latitude: self.offense2Lat, longitude: self.offense2Long))
            let distance3 = currentCoordinate.distanceFromLocation(CLLocation(latitude: self.offense3Lat, longitude: self.offense3Long))
            let distance4 = currentCoordinate.distanceFromLocation(CLLocation(latitude: self.offense4Lat, longitude: self.offense4Long))
            let distance5 = currentCoordinate.distanceFromLocation(CLLocation(latitude: self.offense5Lat, longitude: self.offense5Long))
            let distanceArray = [distance1,distance2,distance3,distance4,distance5]
            print("distanceArray \(distanceArray)")
            var minDistance: Double = 99999999999.0
            var iteration = 0
            var closestOpponent = 0
            for distance in distanceArray {
                iteration++
                if distance < minDistance {
                    minDistance = distance
                    closestOpponent = iteration
                }
                print("iteration: \(iteration)")
                print("distance: \(distance)")
                print("minDistance: \(minDistance)")
                print("closest opp: \(closestOpponent)")
            }
            
            print("final iteration: \(iteration)")
            print("final minDistance: \(minDistance)")
            print("final closest opp: \(closestOpponent)")
            var sickleHit = true
            if closestOpponent == 1 && offense1Status == 1 {
                self.logEvent("Tagged \(offense1var) with sickle!")
                self.revealTagee(offense1var)
                playerTagCount++
            }
            else if closestOpponent == 2 && offense2Status == 1 {
                self.logEvent("Tagged \(offense2var) with sickle!")
                self.revealTagee(offense2var)
                playerTagCount++
            }
            else if closestOpponent == 3 && offense3Status == 1 {
                self.logEvent("Tagged \(offense3var) with sickle!")
                self.revealTagee(offense3var)
                playerTagCount++
            }
            else if closestOpponent == 4 && offense4Status == 1 {
                self.logEvent("Tagged \(offense4var) with sickle!")
                self.revealTagee(offense4var)
                playerTagCount++
            }
            else if closestOpponent == 5 && offense5Status == 1 {
                self.logEvent("Tagged \(offense5var) with sickle!")
                self.revealTagee(offense5var)
                playerTagCount++
            }
            else {
                self.logEvent("Sickle missed!")
                sickleHit = false
            }
            
            if sickleHit == true {
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.displayAlert("Error", message: "Network error, try agian")
                } else if let itemInfo = itemInfo {
                    let nonceTemp = Int(arc4random_uniform(999999))
                    itemInfo["offense\(closestOpponent)Inbox"] = [15,globalUserName,nonceTemp]
                    itemInfo.saveEventually()
                }
            }
            }
            clearAfterUse()
            
        }
        
        //lightning 
        if self.activePowerup == 16 {
            
            self.lightning?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
                if let itemInfo = itemInfo {
                    let rand = Int(arc4random_uniform(999999))
                    itemInfo["offenseInbox"] = [16,rand,globalUserName]
                    itemInfo.saveEventually()
                    
                    if defense1var != "" {
                        self.revealTagee(defense1var)
                    }
                    if defense2var != "" {
                        self.revealTagee(defense2var)
                    }
                    if defense3var != "" {
                        self.revealTagee(defense3var)
                    }
                    if defense4var != "" {
                        self.revealTagee(defense4var)
                    }
                    if defense5var != "" {
                        self.revealTagee(defense5var)
                    }
                    
                }
            }
            let nonceTemp = Int(arc4random_uniform(999999))
            self.postTag(globalUserName, tagee: "na", method: 4, nonce: nonceTemp, hadFlag: false)
            self.logEvent("Lightning tagged all opponents!")
            self.lightningScan()
            self.lightningScanCount = 1
            clearAfterUse()
        }
    }
    
    @IBAction func helpButton(sender: AnyObject) {
        if self.activePowerup == 1 {
            displayAlert("Scan", message: "Reveals the location of all opponents in a selected area of the map")
        }
        if self.activePowerup == 2 {
            displayAlert("Super Scan", message: "Reveals the location of all opponents for about 20 seconds")
        }
        if self.activePowerup == 3 {
            displayAlert("Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging them.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
        }
        if self.activePowerup == 4 {
             displayAlert("Super Mine", message: "Plants a mine on the map that triggers when an opponent gets near, tagging all opponents in the area.  Must be planted within 20 feet from you, and can't be planted in the base or flag zones.")
        }
        if self.activePowerup == 5 {
            displayAlert("Bomb", message: "Tags all players (even teammates) in a selected area of the map.  Can't be dropped in the flag zone.")
        }
        if self.activePowerup == 6 {
            displayAlert("Super Bomb", message: "Tags all players (even teammates) in a selected area of the map (larger reach than the regular bomb.  Can't be dropped in the flag zone.")
        }
        if self.activePowerup == 7 {
            displayAlert("Jammer", message: "When an opponent scans, it will not reveal the location of any opponents.  Lasts one minute. ")
        }
        if self.activePowerup == 8 {
            displayAlert("Spybot", message: "Gets planted at a selected point on the map, and reveals all opponents locations within that area.  Lasts two minutes.")
        }
        if self.activePowerup == 9 {
            displayAlert("Heal", message: "Recharges you (don't need to return to base)")
        }
        if self.activePowerup == 10 {
            displayAlert("Team Heal", message: "Recharges your whole team (don't need to return to base)")
        }
        if self.activePowerup == 11 {
            displayAlert("Shield", message: "Takes longer to get tagged")
        }
        if self.activePowerup == 12 {
            displayAlert("Ghost", message: "All opponents lose all stored items.  Your entire team becomes invisible for one minute.")
        }
        if self.activePowerup == 13 {
            displayAlert("Reach", message: "Can tag opponents from futher away.  Lasts one minute.")
        }
        if self.activePowerup == 14 {
            displayAlert("Sense", message: "Detect opponents' locations when they are near")
        }
        if self.activePowerup == 15 {
            displayAlert("Sickle", message: "Tags the opponent closest to you")
        }
        if self.activePowerup == 16 {
            displayAlert("Lightning", message: "Tags all opponents")
        }
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.itemViewHidden = true
        self.targetImageView.hidden = true
        self.itemButtonBackdropImageView.hidden = true
        self.itemLabelIconImageView.hidden = true
        self.itemLabel.hidden = true
        self.useButtonOutlet.hidden = true
        self.helpButtonOutlet.hidden = true
        self.cancelButtonOutlet.hidden = true
        mapView.pitchEnabled = true
        mapView.zoomEnabled = true
        self.backsound?.play()
    }

    //broadcast beacon signal
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
        self.peripheralManager.startAdvertising(self.advertisedData as? [String : AnyObject])
            bluetoothOn = true
        }
        else if peripheral.state == CBPeripheralManagerState.PoweredOff || peripheral.state == CBPeripheralManagerState.Unsupported || peripheral.state == CBPeripheralManagerState.Unauthorized {
            print("Stopped")
            bluetoothOn = false
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //location manager to monitor user's current lat/long
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.currentLatitude = location.latitude
        self.currentLongitude = location.longitude
        
        
        
        //set up 3d map camera
//        if self.mapSetup < 6 {
        if initialMapSetup == false {
            self.initialMapSetup = true
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.mapCamera = MKMapCamera(lookingAtCenterCoordinate: center, fromDistance: 400, pitch: 25, heading: 45)
        self.mapView.setCamera(self.mapCamera, animated: false)
        }
//        self.mapSetup++
//        }
    }
    
   
    
//beacon detection func
func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion detectionRegion: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0) {

            var closestBeacon = knownBeacons[0] as CLBeacon
            
            if closestBeacon.minor != 5766 && closestBeacon.minor != 5767 && closestBeacon.minor != 5768 && closestBeacon.minor != 5769 && closestBeacon.minor != 5760 && closestBeacon.minor != 33826 {
                for beacon in knownBeacons {
                    if beacon.minor == 5766 || beacon.minor == 5767 || beacon.minor == 5768 || beacon.minor == 5769 || beacon.minor == 5760 || beacon.minor == 33826 {
                        closestBeacon = beacon as CLBeacon
                        break
                    }
                }
                
            }
            
            for beacon in knownBeacons {
                if beacon.rssi > closestBeacon.rssi && (beacon.minor == 5766 || beacon.minor == 5767 || beacon.minor == 5768 || beacon.minor == 5769 || beacon.minor == 5760 || beacon.minor == 33826) {
                    closestBeacon = beacon as CLBeacon
                }
            }
    
    
           // let closestBeacon = knownBeacons[0] as CLBeacon
            //print(closestBeacon)
            
//            //prevent giant leaps in the rssi value, limit increment to 5 in either direction
////            currentRSSI2 = currentRSSI1
            currentRSSI1 = closestBeacon.rssi
////            if currentRSSI1 - currentRSSI2 > 20 {
////                currentRSSI1 = currentRSSI2 + 20
////            }
////            if currentRSSI2 - currentRSSI1 > 20 {
////                currentRSSI1 = currentRSSI2 - 20
////            }
        
    //Display the current RSSI value on the UI
            var currentRSSIString = String(currentRSSI1)
            self.RSSILabel.text = "RSSI: \(currentRSSIString)"
    
        
        if self.shieldLevel == 0 {
            //if defender is appropriate distance, set to 5 life
            if currentRSSI1 < -98 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                
                self.lifeMeterImageView.image = UIImage(named:"5life.png")

            }
            
            //if defender is appropriate distance, set to 3 life
            if currentRSSI1 > -98 && currentRSSI1 <= -84 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                
                self.lifeMeterImageView.image = UIImage(named:"3life.png")
                
            }
            
            //if defender is appropriate distance, set to 1 life
            if currentRSSI1 > -84 && localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767  || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) {
                
                self.lifeMeterImageView.image = UIImage(named:"1life.png")
              
            }
        }
            
    //check to see if "tagged" (threshold exceeded), and if so vibrate, play sound, and reset current RSSI value to a high number as a "cool down" timer
            if localPlayerStatus == 1 && (closestBeacon.minor == 5766 || closestBeacon.minor == 5767 || closestBeacon.minor == 5768 || closestBeacon.minor == 5769 || closestBeacon.minor == 5760 || closestBeacon.minor == 33826) && (currentRSSI1 > tagThreshold || (self.reachCount > 0 && currentRSSI1 > (tagThreshold - 6)  && closestBeacon.minor == self.reachPlayer)) {
                
                var tagger = ""
                
                if self.shieldLevel == 0 {
                if closestBeacon.minor == 5766 { self.localPlayerTaggedBy = "defense1"
                self.logEvent("Tagged by \(defense1var)!")
                    tagger = defense1var
                }
                if closestBeacon.minor == 5767 { self.localPlayerTaggedBy = "defense2"
                self.logEvent("Tagged by \(defense2var)!")
                    tagger = defense2var
                }
                if closestBeacon.minor == 5768 { self.localPlayerTaggedBy = "defense3"
                self.logEvent("Tagged by \(defense3var)!")
                    tagger = defense3var
                }
                if closestBeacon.minor == 5769 { self.localPlayerTaggedBy = "defense4"
                self.logEvent("Tagged by \(defense4var)!")
                    tagger = defense4var
                }
                if closestBeacon.minor == 5760 { self.localPlayerTaggedBy = "defense5"
                self.logEvent("Tagged by \(defense5var)!")
                    tagger = defense5var
                }
                if closestBeacon.minor == 33826 { self.localPlayerTaggedBy = "beacon"
                self.logEvent("Tagged by the blue beacon!")
                    tagger = "blue beacon"
                }
                
                localPlayerStatus = 0
                self.captureTimer.invalidate()
                
                var hadFlagTemp = false
                let rand = Int(arc4random_uniform(999999))
                self.postTag(tagger, tagee: globalUserName, method: 0, nonce: rand, hadFlag: self.localPlayerCapturedPoint)
                
                self.lifeMeterImageView.image = UIImage(named:"0life.png")
                self.logicCapturing2?.stop()
                self.logicCapturing2?.currentTime = 0
                self.captureTimer.invalidate()
                self.flagImageView.hidden = true
                
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.logicLoseLife?.play()
                    
                //start tag timer
                self.tagTimerCount = 1
                self.tagTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("tagTimerUpdate"), userInfo: nil, repeats: true)
                self.tagTimer.tolerance = 0.3
                        
                        //indicate who tagged the player
//                        inGameInfo["playerTaggedBy"] = self.localPlayerTaggedBy
//                        inGameInfo["playerTagged"] = globalUserName


                    //if tagged player was carrying flag or capturing it, reset PARSE and local variables
                        if self.localPlayerCapturedPoint  == true || self.localPlayerCapturingPoint == true {
                            
                            if self.localPlayerCapturedPoint == true {
                                self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
                                self.inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
                                self.inGameInfo["playerWithPointTaggedName"] = globalUserName
                            }
                            
                            self.inGameInfo["playerCapturingPoint"] = "n"
                            self.inGameInfo["playerCapturedPoint"] = "n"
                            self.inGameInfo["playerCapturingPointPosition"] = "n"
                            self.inGameInfo["playerCapturedPointPosition"] = "n"
                            
                        }
                    
                    self.localPlayerCapturingPoint = false
                    self.localPlayerCapturedPoint = false
   
                        self.inGameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                            if error != nil {
                                print(error)
                                self.logEvent("Trying to connect to network..")
                            }
                            
                        }

                    
                }
                else {
                    self.shieldLevel--
                    if self.shieldLevel == 3 {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.shield?.play()
                        self.logEvent("Shield cracked!")
                        self.lifeMeterImageView.image = UIImage(named:"lifecrackedshield.png")
                    }
                    if self.shieldLevel == 0 {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.shield?.play()
                        self.logEvent("Shield broken!")
                        self.lifeMeterImageView.image = UIImage(named:"3life.png")
                    }
                }
            }
        }
    }
    //end beacon detection function
    
    
//RADIUS OVERLAY ON POINT AND BASE PIN MAP ANNOTATIONS
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay as! MKCircle  == self.baseCircle {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.5
        overlayRenderer.strokeColor = UIColor.blueColor()
        return overlayRenderer
        }
        
        else if overlay as! MKCircle  == self.mine1Circle || overlay as! MKCircle  == self.mine2Circle || overlay as! MKCircle  == self.mine1VCircle || overlay as! MKCircle  == self.mine2VCircle || overlay as! MKCircle  == self.mine3VCircle || overlay as! MKCircle  == self.mine4VCircle || overlay as! MKCircle  == self.mine5VCircle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.440, green:0.138, blue:0.456, alpha:1.00)
            return overlayRenderer
        }
            
        else if overlay as! MKCircle  == self.drop1Circle || overlay as! MKCircle  == self.drop2Circle || overlay as! MKCircle  == self.drop3Circle || overlay as! MKCircle  == self.drop4Circle || overlay as! MKCircle  == self.drop5Circle || overlay as! MKCircle  == self.tempdropcircle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.957, green:0.565, blue:0.000, alpha:1.00)
            return overlayRenderer
        }
            
        else if overlay as! MKCircle  == self.spybot1Circle || overlay as! MKCircle  == self.spybot2Circle || overlay as! MKCircle  == self.spybot3Circle {
            let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
            overlayRenderer.lineWidth = 1.0
            overlayRenderer.strokeColor = UIColor(red:0.252, green:1.000, blue:0.432, alpha:1.00)
            return overlayRenderer
        }
        
        else {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.5
        overlayRenderer.strokeColor = UIColor.redColor()
        return overlayRenderer
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        //set base graphic
        if annotation is MKPointAnnotation {
            let pin2 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin2")
            pin2.pinTintColor = UIColor.redColor()
            pin2.canShowCallout = true
            return pin2
                }

        //set offense pins to blue color
        if annotation is CustomPinBlue {
            let pin3 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin3")
            pin3.pinTintColor = UIColor.blueColor()
            pin3.canShowCallout = true
            return pin3
        }
        
        if annotation is CustomPinBase {
            let baseDropPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "baseDropPin")
            baseDropPin.canShowCallout = true
            baseDropPin.image = UIImage(named:"basePin.png")
            baseDropPin.frame.size.height = 80
            baseDropPin.frame.size.width = 27
            return baseDropPin
        }
        
        if annotation is CustomPinDrop {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "minePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"questionBox.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        if annotation is CustomPinScan {
            let scanPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "scanPin")
            scanPin.canShowCallout = true
            scanPin.image = UIImage(named:"radar.png")
            scanPin.frame.size.height = 148
            scanPin.frame.size.width = 150
            return scanPin
        }
        if annotation is CustomPinMine {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "minePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"mineSmall.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        
        if annotation is CustomPinSupermine {
            let minePin = MKAnnotationView(annotation: annotation, reuseIdentifier: "superminePin")
            minePin.canShowCallout = true
            minePin.image = UIImage(named:"superminePin.png")
            minePin.frame.size.height = 80
            minePin.frame.size.width = 27
            return minePin
        }
        
        if annotation is CustomPinBomb {
            let bombPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bombPin")
            bombPin.canShowCallout = true
            bombPin.image = UIImage(named:"explosion.png")
            bombPin.frame.size.height = 92
            bombPin.frame.size.width = 100
            return bombPin
        }
        
        if annotation is CustomPinSuperbomb {
            let bombPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "superbombPin")
            bombPin.canShowCallout = true
            bombPin.image = UIImage(named:"explosion2.png")
            bombPin.frame.size.height = 151
            bombPin.frame.size.width = 150
            return bombPin
        }
        
        if annotation is CustomPinSpybot {
            let spybotPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "spybotPin")
            spybotPin.canShowCallout = true
            spybotPin.image = UIImage(named:"spybotPin.png")
            spybotPin.frame.size.height = 80
            spybotPin.frame.size.width = 27
            return spybotPin
        }
        
        if annotation is CustomPinBlueperson {
            let bluepersonPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonPin")
            bluepersonPin.canShowCallout = true
            bluepersonPin.image = UIImage(named:"blueperson.png")
            bluepersonPin.frame.size.height = 80
            bluepersonPin.frame.size.width = 29
            return bluepersonPin
        }
        
        if annotation is CustomPinBluepersonX {
            let bluepersonXPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonXPin")
            bluepersonXPin.canShowCallout = true
            bluepersonXPin.image = UIImage(named:"bluepersonX.png")
            bluepersonXPin.frame.size.height = 80
            bluepersonXPin.frame.size.width = 29
            return bluepersonXPin
        }
        
        if annotation is CustomPinBluepersonflag {
            let bluepersonflagPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "bluepersonflagPin")
            bluepersonflagPin.canShowCallout = true
            bluepersonflagPin.image = UIImage(named:"bluepersonflag.png")
            bluepersonflagPin.frame.size.height = 80
            bluepersonflagPin.frame.size.width = 29
            return bluepersonflagPin
        }
        
        if annotation is CustomPinRedperson {
            let redpersonPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "redpersonPin")
            redpersonPin.canShowCallout = true
            redpersonPin.image = UIImage(named:"redperson.png")
            redpersonPin.frame.size.height = 80
            redpersonPin.frame.size.width = 29
            return redpersonPin
        }
        
        if annotation is CustomPinRedpersonX {
            let redpersonXPin = MKAnnotationView(annotation: annotation, reuseIdentifier: "redpersonXPin")
            redpersonXPin.canShowCallout = true
            redpersonXPin.image = UIImage(named:"redpersonX.png")
            redpersonXPin.frame.size.height = 80
            redpersonXPin.frame.size.width = 29
            return redpersonXPin
        }
        
        
        //set flag graphic (map annotation)
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.canShowCallout = true
        pin.image = UIImage(named:"robotMapFlag.png")
        pin.frame.size.height = 120
        pin.frame.size.width = 80
        return pin
        
    }
    
    
//game timer
    func gameTimerUpdate() {
        if(gameTimerCount > 0)
        {
        gameTimerCount--
        let min = gameTimerCount / 60
        let sec = gameTimerCount % 60
        var secStr = String(sec)
        
            if secStr.characters.count == 1 {
                secStr = "0\(secStr)"
            }
            
        self.timeLabel.text = "\(min):\(secStr)"
            
        //clear the events label after displaying the same text for a few seconds
            if gameTimerCount % 5 == 0 {
                
                self.eventsLabelCurrent = String(self.eventsLabel.text)
                if self.eventsLabelCurrent == self.eventsLabelLast {
                self.eventsLabelResetCount++
                if self.eventsLabelResetCount == 2 {
                    self.eventsLabelResetCount = 0
                    self.eventsLabel.text = ""
                    }
                }
                self.eventsLabelLast = self.eventsLabelCurrent
            }
            
        }
        if(gameTimerCount == 0)
        {
        globalDefenseWonGame = true
            self.captureTimer.invalidate()
            self.itemTimer.invalidate()
            self.gameTimer.invalidate()
            self.offenseSystemTimer.invalidate()
            self.defenseSystemTimer.invalidate()
            self.defenseRechargeTimer.invalidate()
            self.errorCorrectionSystemTimer.invalidate()
            self.timerSyncSystemTimer.invalidate()
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
            self.locationManager.stopUpdatingLocation()
        self.performSegueWithIdentifier("showGameResultsViewController", sender: nil)
        }
        
    }
    
    
//item timer
    func itemTimerUpdate() {
        if(self.itemTimerCount > 0)
        {
            self.itemTimerCount--
        }
        if(self.itemTimerCount == 2)
        {
            if globalIsOffense == true {
                //mine 1
                if self.mine1Dropped == true {
                    if self.mine1region.containsCoordinate(self.defense1Coordinates) || self.mine1region.containsCoordinate(self.defense2Coordinates) || self.mine1region.containsCoordinate(self.defense3Coordinates) || self.mine1region.containsCoordinate(self.defense4Coordinates) || self.mine1region.containsCoordinate(self.defense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        
                        if self.mine1region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense1Inbox")
                            self.revealTagee(defense1var)
                            playerTaggedByMine = defense1var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense2Inbox")
                            self.revealTagee(defense2var)
                            playerTaggedByMine = defense2var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense3Inbox")
                            self.revealTagee(defense3var)
                            playerTaggedByMine = defense3var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense4Inbox")
                            self.revealTagee(defense4var)
                            playerTaggedByMine = defense4var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense5Inbox")
                            self.revealTagee(defense5var)
                            playerTaggedByMine = defense5var
                            playersTaggedByMine++
                        }
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine1Dropped = false
                        
                        if self.mine1isSuper == false {
                            self.mapView.removeAnnotation(self.mine1DropPin)
                        }
                        if self.mine1isSuper == true {
                            self.mapView.removeAnnotation(self.supermine1DropPin)
                        }
                        self.mapView.removeOverlay(self.mine1Circle)
                        self.unpostMine(self.mine1Nonce)
                    }
                }
                //mine2
                if self.mine2Dropped == true {
                    if self.mine2region.containsCoordinate(self.defense1Coordinates) || self.mine2region.containsCoordinate(self.defense2Coordinates) || self.mine2region.containsCoordinate(self.defense3Coordinates) || self.mine2region.containsCoordinate(self.defense4Coordinates) || self.mine2region.containsCoordinate(self.defense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        if self.mine2region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense1Inbox")
                            self.revealTagee(defense1var)
                            playerTaggedByMine = defense1var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense2Inbox")
                            self.revealTagee(defense2var)
                            playerTaggedByMine = defense2var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense3Inbox")
                            self.revealTagee(defense3var)
                            playerTaggedByMine = defense3var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense4Inbox")
                            self.revealTagee(defense4var)
                            playerTaggedByMine = defense4var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense5Inbox")
                            self.revealTagee(defense5var)
                            playerTaggedByMine = defense5var
                            playersTaggedByMine++
                        }
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine2Dropped = false
                        
                        if self.mine2isSuper == false {
                            self.mapView.removeAnnotation(self.mine2DropPin)
                        }
                        if self.mine2isSuper == true {
                            self.mapView.removeAnnotation(self.supermine2DropPin)
                        }
                        self.mapView.removeOverlay(self.mine2Circle)
                        self.unpostMine(self.mine2Nonce)
                    }
                }
                //mine3
                if self.mine3Dropped == true {
                    if self.mine3region.containsCoordinate(self.defense1Coordinates) || self.mine3region.containsCoordinate(self.defense2Coordinates) || self.mine3region.containsCoordinate(self.defense3Coordinates) || self.mine3region.containsCoordinate(self.defense4Coordinates) || self.mine3region.containsCoordinate(self.defense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        if self.mine3region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense1Inbox")
                            self.revealTagee(defense1var)
                            playerTaggedByMine = defense1var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense2Inbox")
                            self.revealTagee(defense2var)
                            playerTaggedByMine = defense2var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense3Inbox")
                            self.revealTagee(defense3var)
                            playerTaggedByMine = defense3var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense4Inbox")
                            self.revealTagee(defense4var)
                            playerTaggedByMine = defense4var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "defense5Inbox")
                            self.revealTagee(defense5var)
                            playerTaggedByMine = defense5var
                            playersTaggedByMine++
                        }
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine3Dropped = false
                        
                        if self.mine3isSuper == false {
                            self.mapView.removeAnnotation(self.mine3DropPin)
                        }
                        if self.mine3isSuper == true {
                            self.mapView.removeAnnotation(self.supermine3DropPin)
                        }
                        self.mapView.removeOverlay(self.mine3Circle)
                        self.unpostMine(self.mine3Nonce)
                    }
                }
            }
            else {
                //mine 1
                if self.mine1Dropped == true {
                    if self.mine1region.containsCoordinate(self.offense1Coordinates) || self.mine1region.containsCoordinate(self.offense2Coordinates) || self.mine1region.containsCoordinate(self.offense3Coordinates) || self.mine1region.containsCoordinate(self.offense4Coordinates) || self.mine1region.containsCoordinate(self.offense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        if self.mine1region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense1Inbox")
                            self.revealTagee(offense1var)
                            playerTaggedByMine = offense1var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense2Inbox")
                            self.revealTagee(offense2var)
                            playerTaggedByMine = offense2var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense3Inbox")
                            self.revealTagee(offense3var)
                            playerTaggedByMine = offense3var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense4Inbox")
                            self.revealTagee(offense4var)
                            playerTaggedByMine = offense4var
                            playersTaggedByMine++
                        }
                        if self.mine1region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense5Inbox")
                            self.revealTagee(offense5var)
                            playerTaggedByMine = offense5var
                            playersTaggedByMine++
                        }
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine1Dropped = false
                        
                        if self.mine1isSuper == false {
                            self.mapView.removeAnnotation(self.mine1DropPin)
                        }
                        if self.mine1isSuper == true {
                            self.mapView.removeAnnotation(self.supermine1DropPin)
                        }
                        self.mapView.removeOverlay(self.mine1Circle)
                        self.unpostMine(self.mine1Nonce)
                    }
                }
                //mine2
                if self.mine2Dropped == true {
                    if self.mine2region.containsCoordinate(self.offense1Coordinates) || self.mine2region.containsCoordinate(self.offense2Coordinates) || self.mine2region.containsCoordinate(self.offense3Coordinates) || self.mine2region.containsCoordinate(self.offense4Coordinates) || self.mine2region.containsCoordinate(self.offense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        if self.mine2region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense1Inbox")
                            self.revealTagee(offense1var)
                            playerTaggedByMine = offense1var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense2Inbox")
                            self.revealTagee(offense2var)
                            playerTaggedByMine = offense2var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense3Inbox")
                            self.revealTagee(offense3var)
                            playerTaggedByMine = offense3var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense4Inbox")
                            self.revealTagee(offense4var)
                            playerTaggedByMine = offense4var
                            playersTaggedByMine++
                        }
                        if self.mine2region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense5Inbox")
                            self.revealTagee(offense5var)
                            playerTaggedByMine = offense5var
                            playersTaggedByMine++
                        }
                        
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine2Dropped = false
                        
                        if self.mine2isSuper == false {
                            self.mapView.removeAnnotation(self.mine2DropPin)
                        }
                        if self.mine2isSuper == true {
                            self.mapView.removeAnnotation(self.supermine2DropPin)
                        }
                        self.mapView.removeOverlay(self.mine2Circle)
                        self.unpostMine(self.mine2Nonce)
                    }
                }
                //mine3
                if self.mine3Dropped == true {
                    if self.mine3region.containsCoordinate(self.offense1Coordinates) || self.mine3region.containsCoordinate(self.offense2Coordinates) || self.mine3region.containsCoordinate(self.offense3Coordinates) || self.mine3region.containsCoordinate(self.offense4Coordinates) || self.mine3region.containsCoordinate(self.offense5Coordinates) {
                        
                        var playerTaggedByMine = ""
                        var playersTaggedByMine = 0
                        if self.mine3region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense1Inbox")
                            self.revealTagee(offense1var)
                            playerTaggedByMine = offense1var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense2Inbox")
                            self.revealTagee(offense2var)
                            playerTaggedByMine = offense2var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense3Inbox")
                            self.revealTagee(offense3var)
                            playerTaggedByMine = offense3var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense4Inbox")
                            self.revealTagee(offense4var)
                            playerTaggedByMine = offense4var
                            playersTaggedByMine++
                        }
                        if self.mine3region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
                            self.postMineTag(globalUserName, inbox: "offense5Inbox")
                            self.revealTagee(offense5var)
                            playerTaggedByMine = offense5var
                            playersTaggedByMine++
                        }
                        
                        if playersTaggedByMine > 1 {
                            self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
                        }
                        else if playersTaggedByMine == 1 {
                            self.logEvent("Mine triggered on \(playerTaggedByMine)")
                        }
                        else if playersTaggedByMine == 0 {
                            self.logEvent("Mine tripped by tagged player!")
                        }
                        
                        self.mine3Dropped = false
                        
                        if self.mine3isSuper == false {
                            self.mapView.removeAnnotation(self.mine3DropPin)
                        }
                        if self.mine3isSuper == true {
                            self.mapView.removeAnnotation(self.supermine3DropPin)
                        }
                        self.mapView.removeOverlay(self.mine3Circle)
                        self.unpostMine(self.mine3Nonce)
                    }
                }
            }
        }
        if(self.itemTimerCount == 0)
        {
            print("item timer fired, count: \(itemTimerCount)")
            itemInfo.fetchInBackgroundWithBlock {
                (itemInfo: PFObject?, error: NSError?) -> Void in
            //2-10 changed from:    if error == nil {     , removed ? after itemInfo(()).objectFor..
                if let itemInfo = itemInfo {
            
        if globalIsOffense == true {
                    self.OI1 = itemInfo.objectForKey("OI1") as! NSArray
                    self.OI2 = itemInfo.objectForKey("OI2") as! NSArray
                    self.OI3 = itemInfo.objectForKey("OI3") as! NSArray
                    self.OI4 = itemInfo.objectForKey("OI4") as! NSArray
                    self.OI5 = itemInfo.objectForKey("OI5") as! NSArray
                    self.OS = itemInfo.objectForKey("OS") as! NSArray
                    self.OS2 = itemInfo.objectForKey("OS2") as! NSArray
                    self.OM = itemInfo.objectForKey("OM") as! NSArray
                    self.OM2 = itemInfo.objectForKey("OM2") as! NSArray
                    self.OMU = itemInfo.objectForKey("OMU") as! NSArray
                    self.OMU2 = itemInfo.objectForKey("OMU2") as! NSArray
                    }
                    
        if globalIsOffense == false {
                    self.DI1 = itemInfo.objectForKey("DI1") as! NSArray
                    self.DI2 = itemInfo.objectForKey("DI2") as! NSArray
                    self.DI3 = itemInfo.objectForKey("DI3") as! NSArray
                    self.DI4 = itemInfo.objectForKey("DI4") as! NSArray
                    self.DI5 = itemInfo.objectForKey("DI5") as! NSArray
                    self.DS = itemInfo.objectForKey("DS") as! NSArray
                    self.DS2 = itemInfo.objectForKey("DS2") as! NSArray
                    self.DM = itemInfo.objectForKey("DM") as! NSArray
                    self.DM2 = itemInfo.objectForKey("DM2") as! NSArray
                    self.DMU = itemInfo.objectForKey("DMU") as! NSArray
                    self.DMU2 = itemInfo.objectForKey("DMU2") as! NSArray
                    }
            
            
            self.offense1Inbox = itemInfo.objectForKey("offense1Inbox") as! NSArray
            self.offense2Inbox = itemInfo.objectForKey("offense2Inbox") as! NSArray
            self.offense3Inbox = itemInfo.objectForKey("offense3Inbox") as! NSArray
            self.offense4Inbox = itemInfo.objectForKey("offense4Inbox") as! NSArray
            self.offense5Inbox = itemInfo.objectForKey("offense5Inbox") as! NSArray
            self.offenseInbox = itemInfo.objectForKey("offenseInbox") as! NSArray
            self.offenseInbox2 = itemInfo.objectForKey("offenseInbox2") as! NSArray
            self.offenseInbox3 = itemInfo.objectForKey("offenseInbox3") as! NSArray
            self.offenseInbox4 = itemInfo.objectForKey("offenseInbox4") as! NSArray
            self.defense1Inbox = itemInfo.objectForKey("defense1Inbox") as! NSArray
            self.defense2Inbox = itemInfo.objectForKey("defense2Inbox") as! NSArray
            self.defense3Inbox = itemInfo.objectForKey("defense3Inbox") as! NSArray
            self.defense4Inbox = itemInfo.objectForKey("defense4Inbox") as! NSArray
            self.defense5Inbox = itemInfo.objectForKey("defense5Inbox") as! NSArray
            self.defenseInbox = itemInfo.objectForKey("defenseInbox") as! NSArray
            self.defenseInbox2 = itemInfo.objectForKey("defenseInbox2") as! NSArray
            self.defenseInbox3 = itemInfo.objectForKey("defenseInbox3") as! NSArray
            self.defenseInbox4 = itemInfo.objectForKey("defenseInbox4") as! NSArray
            
            //determine whether all 5 items dropped on map
            if self.drop1Dropped == true && self.drop1Dropped == true && self.drop1Dropped == true && self.drop1Dropped == true && self.drop1Dropped == true {
                        self.all5Dropped = true
                    }
                else {
                        self.all5Dropped = false
                    }
            
            //roll for drop
            self.weightedDropRoll()
                    
            //pick up item if in region
            let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
                if self.drop1Dropped == true {
                    if self.drop1Region.containsCoordinate(currentCoordinate) {
                        print("picked up item")
                        self.drop1Dropped = false
                        self.mapView.removeAnnotation(self.drop1DropPin)
                        self.mapView.removeOverlay(self.drop1Circle)
                        self.genItem()
                        self.unpostItem(self.drop1Coordinates.latitude)
                        self.coin?.play()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                }
                    if self.drop2Dropped == true {
                        if self.drop2Region.containsCoordinate(currentCoordinate) {
                            print("picked up item")
                            self.drop2Dropped = false
                            self.mapView.removeAnnotation(self.drop2DropPin)
                            self.mapView.removeOverlay(self.drop2Circle)
                            self.genItem()
                            self.unpostItem(self.drop2Coordinates.latitude)
                            self.coin?.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    if self.drop3Dropped == true {
                        if self.drop3Region.containsCoordinate(currentCoordinate) {
                            print("picked up item")
                            self.drop3Dropped = false
                            self.mapView.removeAnnotation(self.drop3DropPin)
                            self.mapView.removeOverlay(self.drop3Circle)
                            self.genItem()
                            self.unpostItem(self.drop3Coordinates.latitude)
                            self.coin?.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    if self.drop4Dropped == true {
                        if self.drop4Region.containsCoordinate(currentCoordinate) {
                            print("picked up item")
                            self.drop4Dropped = false
                            self.mapView.removeAnnotation(self.drop4DropPin)
                            self.mapView.removeOverlay(self.drop4Circle)
                            self.genItem()
                            self.unpostItem(self.drop4Coordinates.latitude)
                            self.coin?.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    if self.drop5Dropped == true {
                        if self.drop5Region.containsCoordinate(currentCoordinate) {
                            print("picked up item")
                            self.drop5Dropped = false
                            self.mapView.removeAnnotation(self.drop5DropPin)
                            self.mapView.removeOverlay(self.drop5Circle)
                            self.genItem()
                            self.unpostItem(self.drop5Coordinates.latitude)
                            self.coin?.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                
                    
        //post items on the map (rolled by other players), and unmap items picked up by teammates
            if globalIsOffense == true {
            //post items
                if self.OI.contains(Double("\(self.OI1[1] as! Double)")!) == false && Double("\(self.OI1[0] as! Double)") != 0 {
                    self.OI.append(Double("\(self.OI1[1] as! Double)")!)
                    self.mapItem(Double("\(self.OI1[1] as! Double)")!, long: Double("\(self.OI1[2] as! Double)")!)
                }
                if self.OI.contains(Double("\(self.OI2[1] as! Double)")!) == false && Double("\(self.OI2[0] as! Double)") != 0 {
                    self.OI.append(Double("\(self.OI2[1] as! Double)")!)
                    self.mapItem(Double("\(self.OI2[1] as! Double)")!, long: Double("\(self.OI2[2] as! Double)")!)
                }
                if self.OI.contains(Double("\(self.OI3[1] as! Double)")!) == false && Double("\(self.OI3[0] as! Double)") != 0 {
                    self.OI.append(Double("\(self.OI3[1] as! Double)")!)
                    self.mapItem(Double("\(self.OI3[1] as! Double)")!, long: Double("\(self.OI3[2] as! Double)")!)
                }
                if self.OI.contains(Double("\(self.OI4[1] as! Double)")!) == false && Double("\(self.OI4[0] as! Double)") != 0 {
                    self.OI.append(Double("\(self.OI4[1] as! Double)")!)
                    self.mapItem(Double("\(self.OI4[1] as! Double)")!, long: Double("\(self.OI4[2] as! Double)")!)
                }
                if self.OI.contains(Double("\(self.OI5[1] as! Double)")!) == false && Double("\(self.OI5[0] as! Double)") != 0 {
                    self.OI.append(Double("\(self.OI5[1] as! Double)")!)
                    self.mapItem(Double("\(self.OI5[1] as! Double)")!, long: Double("\(self.OI5[2] as! Double)")!)
                }
            //unmap items that were picked up by teammates
                if self.drop1Coordinates.latitude != Double("\(self.OI1[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.OI2[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.OI3[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.OI4[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.OI5[1] as! Double)")  {
                    self.drop1Dropped = false
                    self.mapView.removeAnnotation(self.drop1DropPin)
                    self.mapView.removeOverlay(self.drop1Circle)
                }
                if self.drop2Coordinates.latitude != Double("\(self.OI1[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.OI2[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.OI3[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.OI4[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.OI5[1] as! Double)")  {
                    self.drop2Dropped = false
                    self.mapView.removeAnnotation(self.drop2DropPin)
                    self.mapView.removeOverlay(self.drop2Circle)
                }
                if self.drop3Coordinates.latitude != Double("\(self.OI1[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.OI2[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.OI3[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.OI4[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.OI5[1] as! Double)")  {
                    self.drop3Dropped = false
                    self.mapView.removeAnnotation(self.drop3DropPin)
                    self.mapView.removeOverlay(self.drop3Circle)
                }
                if self.drop4Coordinates.latitude != Double("\(self.OI1[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.OI2[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.OI3[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.OI4[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.OI5[1] as! Double)")  {
                    self.drop4Dropped = false
                    self.mapView.removeAnnotation(self.drop4DropPin)
                    self.mapView.removeOverlay(self.drop4Circle)
                }
                if self.drop5Coordinates.latitude != Double("\(self.OI1[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.OI2[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.OI3[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.OI4[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.OI5[1] as! Double)")  {
                    self.drop5Dropped = false
                    self.mapView.removeAnnotation(self.drop5DropPin)
                    self.mapView.removeOverlay(self.drop5Circle)
                }

            }
            if globalIsOffense == false {
            //post items
                if self.DI.contains(Double("\(self.DI1[1] as! Double)")!) == false && Double("\(self.DI1[0] as! Double)") != 0 {
                    self.DI.append(Double("\(self.DI1[1] as! Double)")!)
                    self.mapItem(Double("\(self.DI1[1] as! Double)")!, long: Double("\(self.DI1[2] as! Double)")!)
                }
                if self.DI.contains(Double("\(self.DI2[1] as! Double)")!) == false && Double("\(self.DI2[0] as! Double)") != 0 {
                    self.DI.append(Double("\(self.DI2[1] as! Double)")!)
                    self.mapItem(Double("\(self.DI2[1] as! Double)")!, long: Double("\(self.DI2[2] as! Double)")!)
                }
                if self.DI.contains(Double("\(self.DI3[1] as! Double)")!) == false && Double("\(self.DI3[0] as! Double)") != 0 {
                    self.DI.append(Double("\(self.DI3[1] as! Double)")!)
                    self.mapItem(Double("\(self.DI3[1] as! Double)")!, long: Double("\(self.DI3[2] as! Double)")!)
                }
                if self.DI.contains(Double("\(self.DI4[1] as! Double)")!) == false && Double("\(self.DI4[0] as! Double)") != 0 {
                    self.DI.append(Double("\(self.DI4[1] as! Double)")!)
                    self.mapItem(Double("\(self.DI4[1] as! Double)")!, long: Double("\(self.DI4[2] as! Double)")!)
                }
                if self.DI.contains(Double("\(self.DI5[1] as! Double)")!) == false && Double("\(self.DI5[0] as! Double)") != 0 {
                    self.DI.append(Double("\(self.DI5[1] as! Double)")!)
                    self.mapItem(Double("\(self.DI5[1] as! Double)")!, long: Double("\(self.DI5[2] as! Double)")!)
                }
            //unmap items that were picked up by teammates
//                if self.drop1Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//                    self.drop1Dropped = false
//                    self.mapView.removeAnnotation(self.drop1DropPin)
//                    self.mapView.removeOverlay(self.drop1Circle)
//                }
//                if self.drop2Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//                    self.drop2Dropped = false
//                    self.mapView.removeAnnotation(self.drop2DropPin)
//                    self.mapView.removeOverlay(self.drop2Circle)
//                }
//                if self.drop3Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//                    self.drop3Dropped = false
//                    self.mapView.removeAnnotation(self.drop3DropPin)
//                    self.mapView.removeOverlay(self.drop3Circle)
//                }
//                if self.drop4Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//                    self.drop4Dropped = false
//                    self.mapView.removeAnnotation(self.drop4DropPin)
//                    self.mapView.removeOverlay(self.drop4Circle)
//                }
//                if self.drop5Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//                    self.drop5Dropped = false
//                    self.mapView.removeAnnotation(self.drop5DropPin)
//                    self.mapView.removeOverlay(self.drop5Circle)
//                }

            }
                  
                    
            //get tagged by mine, if applicable
                    if localPlayerPosition == "offense1" && Int("\(self.offense1Inbox[0] as! Int)") == 3 && Int("\(self.offense1Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.offense1Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense1Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalOffensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "offense2" && Int("\(self.offense2Inbox[0] as! Int)") == 3 && Int("\(self.offense2Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.offense2Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense2Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalOffensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "offense3" && Int("\(self.offense3Inbox[0] as! Int)") == 3 && Int("\(self.offense3Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.offense3Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense3Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalOffensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "offense4" && Int("\(self.offense4Inbox[0] as! Int)") == 3 && Int("\(self.offense4Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.offense4Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense4Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalOffensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "offense5" && Int("\(self.offense5Inbox[0] as! Int)") == 3 && Int("\(self.offense5Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.offense5Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense5Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalOffensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "defense1" && Int("\(self.defense1Inbox[0] as! Int)") == 3 && Int("\(self.defense1Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.defense1Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense1Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalDefensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "defense2" && Int("\(self.defense2Inbox[0] as! Int)") == 3 && Int("\(self.defense2Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.defense2Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense2Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalDefensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "defense3" && Int("\(self.defense3Inbox[0] as! Int)") == 3 && Int("\(self.defense3Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.defense3Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense3Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalDefensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "defense4" && Int("\(self.defense4Inbox[0] as! Int)") == 3 && Int("\(self.defense4Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.defense4Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense4Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalDefensePlayerByMine(taggedByTemp)
                    }
                    if localPlayerPosition == "defense5" && Int("\(self.defense5Inbox[0] as! Int)") == 3 && Int("\(self.defense5Inbox[2] as! Int)") != self.mineTagNonce {
                        self.mineTagNonce = Int("\(self.defense5Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense5Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 1, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalDefensePlayerByMine(taggedByTemp)
                    }
                    
            //get tagged by bomb (if applicable)
                    if localPlayerPosition == "offense1" && Int("\(self.offense1Inbox[0] as! Int)") == 5 && Int("\(self.offense1Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.offense1Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense1Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "offense2" && Int("\(self.offense2Inbox[0] as! Int)") == 5 && Int("\(self.offense2Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.offense2Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense2Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "offense3" && Int("\(self.offense3Inbox[0] as! Int)") == 5 && Int("\(self.offense3Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.offense3Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense3Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "offense4" && Int("\(self.offense4Inbox[0] as! Int)") == 5 && Int("\(self.offense4Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.offense4Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense4Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "offense5" && Int("\(self.offense5Inbox[0] as! Int)") == 5 && Int("\(self.offense5Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.offense5Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense5Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "defense1" && Int("\(self.defense1Inbox[0] as! Int)") == 5 && Int("\(self.defense1Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.defense1Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense1Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "defense2" && Int("\(self.defense2Inbox[0] as! Int)") == 5 && Int("\(self.defense2Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.defense2Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense2Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "defense3" && Int("\(self.defense3Inbox[0] as! Int)") == 5 && Int("\(self.defense3Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.defense3Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense3Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "defense4" && Int("\(self.defense4Inbox[0] as! Int)") == 5 && Int("\(self.defense4Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.defense4Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense4Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    if localPlayerPosition == "defense5" && Int("\(self.defense5Inbox[0] as! Int)") == 5 && Int("\(self.defense5Inbox[2] as! Int)") != self.bombTagNonce {
                        self.bombTagNonce = Int("\(self.defense5Inbox[2] as! Int)")!
                        let taggedByTemp = self.defense5Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 2, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "bomb")
                    }
                    
                //receive teammates mines (view only)
                    if globalIsOffense == true && String("\(self.OM[0] as! String)") != globalUserName && Int("\(self.OM[1] as! Int)") != self.mineNonce1 && Int("\(self.OM[1] as! Int)") != self.mineNonce2 && Int("\(self.OM[1] as! Int)") != self.mineNonce3 && Int("\(self.OM[1] as! Int)") != 0 {
                        self.mineNonce3 = self.mineNonce2
                        self.mineNonce2 = self.mineNonce1
                        self.mineNonce1 = Int("\(self.OM[1] as! Int)")!
                        var isSuperTemp = false
                        if self.OM[5] as! Bool == true {
                            isSuperTemp = true
                            self.logEvent("\(self.OM[0] as! String) dropped a supermine")
                        }
                        else {
                            self.logEvent("\(self.OM[0] as! String) dropped a mine")
                        }
                        self.dropMineView(Double("\(self.OM[2] as! Double)")!, long: Double("\(self.OM[3] as! Double)")!, isSuper: isSuperTemp, player: "\(self.OM[0] as! String)", nonce: self.mineNonce1)

                    }
                    if globalIsOffense == true && String("\(self.OM2[0] as! String)") != globalUserName && Int("\(self.OM2[1] as! Int)") != self.mineNonce1B && Int("\(self.OM2[1] as! Int)") != self.mineNonce2B && Int("\(self.OM2[1] as! Int)") != self.mineNonce3B && Int("\(self.OM2[1] as! Int)") != 0 {
                        self.mineNonce3B = self.mineNonce2B
                        self.mineNonce2B = self.mineNonce1B
                        self.mineNonce1B = Int("\(self.OM2[1] as! Int)")!
                        var isSuperTemp = false
                        if self.OM2[5] as! Bool == true {
                            isSuperTemp = true
                            self.logEvent("\(self.OM2[0] as! String) dropped a supermine")
                        }
                        else {
                            self.logEvent("\(self.OM2[0] as! String) dropped a mine")
                        }
                        self.dropMineView(Double("\(self.OM2[2] as! Double)")!, long: Double("\(self.OM2[3] as! Double)")!, isSuper: isSuperTemp, player: "\(self.OM2[0] as! String)", nonce: self.mineNonce1B)
                    }
                    if globalIsOffense == false && String("\(self.DM[0] as! String)") != globalUserName && Int("\(self.DM[1] as! Int)") != self.mineNonce1 && Int("\(self.DM[1] as! Int)") != self.mineNonce2 && Int("\(self.DM[1] as! Int)") != self.mineNonce3 && Int("\(self.DM[1] as! Int)") != 0 {
                        self.mineNonce3 = self.mineNonce2
                        self.mineNonce2 = self.mineNonce1
                        self.mineNonce1 = Int("\(self.DM[1] as! Int)")!
                        var isSuperTemp = false
                        if self.DM[5] as! Bool == true {
                            isSuperTemp = true
                            self.logEvent("\(self.DM[0] as! String) dropped a supermine")
                        }
                        else {
                            self.logEvent("\(self.DM[0] as! String) dropped a mine")
                        }
                        self.dropMineView(Double("\(self.DM[2] as! Double)")!, long: Double("\(self.DM[3] as! Double)")!, isSuper: isSuperTemp, player: "\(self.DM[0] as! String)", nonce: self.mineNonce1)
                    }
                    if globalIsOffense == false && String("\(self.DM2[0] as! String)") != globalUserName && Int("\(self.DM2[1] as! Int)") != self.mineNonce1B && Int("\(self.DM2[1] as! Int)") != self.mineNonce2B && Int("\(self.DM2[1] as! Int)") != self.mineNonce3B && Int("\(self.DM2[1] as! Int)") != 0 {
                        self.mineNonce3B = self.mineNonce2B
                        self.mineNonce2B = self.mineNonce1B
                        self.mineNonce1B = Int("\(self.DM2[1] as! Int)")!
                        var isSuperTemp = false
                        if self.DM2[5] as! Bool == true {
                            isSuperTemp = true
                            self.logEvent("\(self.DM2[0] as! String) dropped a supermine")
                        }
                        else {
                            self.logEvent("\(self.DM2[0] as! String) dropped a mine")
                        }
                        self.dropMineView(Double("\(self.DM2[2] as! Double)")!, long: Double("\(self.DM2[3] as! Double)")!, isSuper: isSuperTemp, player: "\(self.DM2[0] as! String)", nonce: self.mineNonce1B)
                    }
                    
                //unpost teammates mines (view only)
                    if globalIsOffense == true {
                        if Int("\(self.OMU[0] as! Int)") == self.mine1VNonce {
                            self.mapView.removeAnnotation(self.mine1VDropPin)
                            self.mapView.removeAnnotation(self.supermine1VDropPin)
                            self.mapView.removeOverlay(self.mine1VCircle)
                            self.mine1VDropped = false
                        }
                        if Int("\(self.OMU2[0] as! Int)") == self.mine1VNonce {
                            self.mapView.removeAnnotation(self.mine1VDropPin)
                            self.mapView.removeAnnotation(self.supermine1VDropPin)
                            self.mapView.removeOverlay(self.mine1VCircle)
                            self.mine1VDropped = false
                        }
                        
                        if Int("\(self.OMU[0] as! Int)") == self.mine2VNonce {
                            self.mapView.removeAnnotation(self.mine2VDropPin)
                            self.mapView.removeAnnotation(self.supermine2VDropPin)
                            self.mapView.removeOverlay(self.mine2VCircle)
                            self.mine2VDropped = false
                        }
                        if Int("\(self.OMU2[0] as! Int)") == self.mine2VNonce {
                            self.mapView.removeAnnotation(self.mine2VDropPin)
                            self.mapView.removeAnnotation(self.supermine2VDropPin)
                            self.mapView.removeOverlay(self.mine2VCircle)
                            self.mine2VDropped = false
                        }
                        
                        if Int("\(self.OMU[0] as! Int)") == self.mine3VNonce {
                            self.mapView.removeAnnotation(self.mine3VDropPin)
                            self.mapView.removeAnnotation(self.supermine3VDropPin)
                            self.mapView.removeOverlay(self.mine3VCircle)
                            self.mine3VDropped = false
                        }
                        if Int("\(self.OMU2[0] as! Int)") == self.mine3VNonce {
                            self.mapView.removeAnnotation(self.mine3VDropPin)
                            self.mapView.removeAnnotation(self.supermine3VDropPin)
                            self.mapView.removeOverlay(self.mine3VCircle)
                            self.mine3VDropped = false
                        }
                        
                        if Int("\(self.OMU[0] as! Int)") == self.mine4VNonce {
                            self.mapView.removeAnnotation(self.mine4VDropPin)
                            self.mapView.removeAnnotation(self.supermine4VDropPin)
                            self.mapView.removeOverlay(self.mine4VCircle)
                            self.mine4VDropped = false
                        }
                        if Int("\(self.OMU2[0] as! Int)") == self.mine4VNonce {
                            self.mapView.removeAnnotation(self.mine4VDropPin)
                            self.mapView.removeAnnotation(self.supermine4VDropPin)
                            self.mapView.removeOverlay(self.mine4VCircle)
                            self.mine4VDropped = false
                        }
                        
                        if Int("\(self.OMU[0] as! Int)") == self.mine5VNonce {
                            self.mapView.removeAnnotation(self.mine5VDropPin)
                            self.mapView.removeAnnotation(self.supermine5VDropPin)
                            self.mapView.removeOverlay(self.mine5VCircle)
                            self.mine5VDropped = false
                        }
                        if Int("\(self.OMU2[0] as! Int)") == self.mine5VNonce {
                            self.mapView.removeAnnotation(self.mine5VDropPin)
                            self.mapView.removeAnnotation(self.supermine5VDropPin)
                            self.mapView.removeOverlay(self.mine5VCircle)
                            self.mine5VDropped = false
                        }
                        
                    }
                    
                    if globalIsOffense == false {
                        if Int("\(self.DMU[0] as! Int)") == self.mine1VNonce {
                            self.mapView.removeAnnotation(self.mine1VDropPin)
                            self.mapView.removeAnnotation(self.supermine1VDropPin)
                            self.mapView.removeOverlay(self.mine1VCircle)
                            self.mine1VDropped = false
                        }
                        if Int("\(self.DMU2[0] as! Int)") == self.mine1VNonce {
                            self.mapView.removeAnnotation(self.mine1VDropPin)
                            self.mapView.removeAnnotation(self.supermine1VDropPin)
                            self.mapView.removeOverlay(self.mine1VCircle)
                            self.mine1VDropped = false
                        }
                        
                        if Int("\(self.DMU[0] as! Int)") == self.mine2VNonce {
                            self.mapView.removeAnnotation(self.mine2VDropPin)
                            self.mapView.removeAnnotation(self.supermine2VDropPin)
                            self.mapView.removeOverlay(self.mine2VCircle)
                            self.mine2VDropped = false
                        }
                        if Int("\(self.DMU2[0] as! Int)") == self.mine2VNonce {
                            self.mapView.removeAnnotation(self.mine2VDropPin)
                            self.mapView.removeAnnotation(self.supermine2VDropPin)
                            self.mapView.removeOverlay(self.mine2VCircle)
                            self.mine2VDropped = false
                        }
                        
                        if Int("\(self.DMU[0] as! Int)") == self.mine3VNonce {
                            self.mapView.removeAnnotation(self.mine3VDropPin)
                            self.mapView.removeAnnotation(self.supermine3VDropPin)
                            self.mapView.removeOverlay(self.mine3VCircle)
                            self.mine3VDropped = false
                        }
                        if Int("\(self.DMU2[0] as! Int)") == self.mine3VNonce {
                            self.mapView.removeAnnotation(self.mine3VDropPin)
                            self.mapView.removeAnnotation(self.supermine3VDropPin)
                            self.mapView.removeOverlay(self.mine3VCircle)
                            self.mine3VDropped = false
                        }
                        
                        if Int("\(self.DMU[0] as! Int)") == self.mine4VNonce {
                            self.mapView.removeAnnotation(self.mine4VDropPin)
                            self.mapView.removeAnnotation(self.supermine4VDropPin)
                            self.mapView.removeOverlay(self.mine4VCircle)
                            self.mine4VDropped = false
                        }
                        if Int("\(self.DMU2[0] as! Int)") == self.mine4VNonce {
                            self.mapView.removeAnnotation(self.mine4VDropPin)
                            self.mapView.removeAnnotation(self.supermine4VDropPin)
                            self.mapView.removeOverlay(self.mine4VCircle)
                            self.mine4VDropped = false
                        }
                        
                        if Int("\(self.DMU[0] as! Int)") == self.mine5VNonce {
                            self.mapView.removeAnnotation(self.mine5VDropPin)
                            self.mapView.removeAnnotation(self.supermine5VDropPin)
                            self.mapView.removeOverlay(self.mine5VCircle)
                            self.mine5VDropped = false
                        }
                        if Int("\(self.DMU2[0] as! Int)") == self.mine5VNonce {
                            self.mapView.removeAnnotation(self.mine5VDropPin)
                            self.mapView.removeAnnotation(self.supermine5VDropPin)
                            self.mapView.removeOverlay(self.mine5VCircle)
                            self.mine5VDropped = false
                        }
                        
                    }
                    
                    
                //get inflicted with jammer, if applicable
                    if globalIsOffense == true && Int("\(self.offenseInbox2[0] as! Int)") == 7 && self.jammerNonce != Int("\(self.offenseInbox2[1] as! Int)") {
                        self.jammerNonce = Int("\(self.offenseInbox2[1] as! Int)")!
                        self.jammerCount = 1
                    }
                    if globalIsOffense == false && Int("\(self.defenseInbox2[0] as! Int)") == 7 && self.jammerNonce != Int("\(self.defenseInbox2[1] as! Int)") {
                        self.jammerNonce = Int("\(self.defenseInbox2[1] as! Int)")!
                        self.jammerCount = 1
                    }
                    if self.jammerCount > 0 {
                        self.jammerCount++
                        if self.jammerCount == 9 {
                            self.jammerCount = 0
                        }
                    }
                    
                    //timer, to indicate to jammer owner when it expires
                    if self.ownJammerCount > 0 {
                        self.ownJammerCount++
                        if self.ownJammerCount == 9 {
                            self.ownJammerCount = 0
                            self.logEvent("Jammer expired")
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.removeActiveItemImageView(7)
                        }
                    }
                    
                    //recieve jammer from teammate
                    if globalIsOffense == true && Int("\(self.offenseInbox4[0] as! Int)") == 7 && Int("\(self.offenseInbox4[1] as! Int)") != self.jammerTeammateNonce && String("\(self.offenseInbox4[2] as! String)") != globalUserName {
                        self.jammer?.play()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.jammerTeammateNonce = Int("\(self.offenseInbox4[1] as! Int)")!
                        self.ownJammerCount = 1
                        self.addActiveItemImageView(7)
                        self.logEvent("\(self.offenseInbox4[2] as! String) used a jammer")
                        
                    }
                    else if globalIsOffense == false && Int("\(self.defenseInbox4[0] as! Int)") == 7 && Int("\(self.defenseInbox4[1] as! Int)") != self.jammerTeammateNonce && String("\(self.defenseInbox4[2] as! String)") != globalUserName {
                        self.jammer?.play()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.jammerTeammateNonce = Int("\(self.defenseInbox4[1] as! Int)")!
                        self.ownJammerCount = 1
                        self.addActiveItemImageView(7)
                        self.logEvent("\(self.defenseInbox4[2] as! String) used a jammer")
                        
                    }
                
            //receive spybot
                    if globalIsOffense == true && String("\(self.OS[0] as! String)") != globalUserName && Int("\(self.OS[1] as! Int)") != self.spybotNonce1 && Int("\(self.OS[1] as! Int)") != self.spybotNonce2 && Int("\(self.OS[1] as! Int)") != 0 {
                        self.spybotNonce2 = self.spybotNonce1
                        self.spybotNonce1 = Int("\(self.OS[1] as! Int)")!
                        self.dropSpybot(Double("\(self.OS[2] as! Double)")!, long: Double("\(self.OS[3] as! Double)")!, player: "\(self.OS[0] as! String)")
                        self.logEvent("\(self.OS[0] as! String) dropped a Spybot")
                    }
                    if globalIsOffense == true && String("\(self.OS2[0] as! String)") != globalUserName && Int("\(self.OS2[1] as! Int)") != self.spybotNonce1B && Int("\(self.OS2[1] as! Int)") != self.spybotNonce2B && Int("\(self.OS2[1] as! Int)") != 0 {
                        self.spybotNonce2B = self.spybotNonce1B
                        self.spybotNonce1B = Int("\(self.OS2[1] as! Int)")!
                        self.dropSpybot(Double("\(self.OS2[2] as! Double)")!, long: Double("\(self.OS2[3] as! Double)")!, player: "\(self.OS2[0] as! String)")
                        self.logEvent("\(self.OS2[0] as! String) dropped a Spybot")
                    }
                    if globalIsOffense == false && String("\(self.DS[0] as! String)") != globalUserName && Int("\(self.DS[1] as! Int)") != self.spybotNonce1 && Int("\(self.DS[1] as! Int)") != self.spybotNonce2 && Int("\(self.DS[1] as! Int)") != 0 {
                        self.spybotNonce2 = self.spybotNonce1
                        self.spybotNonce1 = Int("\(self.DS[1] as! Int)")!
                        self.dropSpybot(Double("\(self.DS[2] as! Double)")!, long: Double("\(self.DS[3] as! Double)")!, player: "\(self.DS[0] as! String)")
                        self.logEvent("\(self.DS[0] as! String) dropped a Spybot")
                    }
                    if globalIsOffense == false && String("\(self.DS2[0] as! String)") != globalUserName && Int("\(self.DS2[1] as! Int)") != self.spybotNonce1B && Int("\(self.DS2[1] as! Int)") != self.spybotNonce2B && Int("\(self.DS2[1] as! Int)") != 0 {
                        self.spybotNonce2B = self.spybotNonce1B
                        self.spybotNonce1B = Int("\(self.DS2[1] as! Int)")!
                        self.dropSpybot(Double("\(self.DS2[2] as! Double)")!, long: Double("\(self.DS2[3] as! Double)")!, player: "\(self.DS2[0] as! String)")
                        self.logEvent("\(self.DS2[0] as! String) dropped a Spybot")
                    }
                    
            //receive notification of heal (defense)
                    if Int("\(self.defenseInbox3[0] as! Int)") == 9 && self.healNotNonce != Int("\(self.defenseInbox3[1] as! Int)")  && globalIsOffense == false {
                        self.healNotNonce = Int("\(self.defenseInbox3[1] as! Int)")!
                        let healedPlayerTemp = self.defenseInbox3[2] as! String
                        self.logEvent("\(healedPlayerTemp) healed!")
                    }
                    
            //receive notification of team heal (defense)
                    if Int("\(self.defenseInbox3[0] as! Int)") == 10 && self.superhealNotNonce != Int("\(self.defenseInbox3[1] as! Int)") && globalIsOffense == false {
                        self.superhealNotNonce = Int("\(self.defenseInbox3[1] as! Int)")!
                        self.logEvent("Entire offense team healed!")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                    
            //receive team heal
                    if Int("\(self.offenseInbox[0] as! Int)") == 10 && self.superhealNonce != Int("\(self.offenseInbox[1] as! Int)")  && globalIsOffense == true {
                        self.superhealNonce = Int("\(self.offenseInbox[1] as! Int)")!
                        self.heal()
                        self.logEvent("Recieved heal!")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                    
            //get inflicted with ghost
                    if globalIsOffense == false && (Int("\(self.defenseInbox[0] as! Int)")) == 12 && self.ghostNonce != Int("\(self.defenseInbox[1] as! Int)") {
                        self.ghostNonce = Int("\(self.defenseInbox[1] as! Int)")!
                        self.jammerCount = 1
                        slot1Powerup = 0
                        slot2Powerup = 0
                        slot3Powerup = 0
                        self.activePowerup = 0
                        self.activePowerupSlot = 0
                        
                        if self.itemViewHidden == false {
                            self.itemViewHidden = true
                            self.targetImageView.hidden = true
                            self.itemButtonBackdropImageView.hidden = true
                            self.itemLabelIconImageView.hidden = true
                            self.itemLabel.hidden = true
                            self.useButtonOutlet.hidden = true
                            self.helpButtonOutlet.hidden = true
                            self.cancelButtonOutlet.hidden = true
                        }
                        self.refreshItems()
                        self.logEvent("Ghosted!!")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.ghost?.play()
                    }
                    
                    //recieve ghost from teammates (for UI purposes only)
                    if globalIsOffense == true && Int("\(self.offenseInbox4[0] as! Int)") == 12 && Int("\(self.offenseInbox4[1] as! Int)") != self.ghostTeammateNonce && String("\(self.offenseInbox4[2] as! String)") != globalUserName {
                        
                        self.ghostTeammateNonce = Int("\(self.offenseInbox4[1] as! Int)")!
                        
                        self.ghost?.play()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        self.ownGhostCount = 1
                        self.addActiveItemImageView(12)
                        self.logEvent("\(self.offenseInbox4[2] as! String) ghosted!")
                        
                    }
                    
                    
                    //timer, to indicate to ghost owner when it expires
                    if self.ownGhostCount > 0 {
                        self.ownGhostCount++
                        if self.ownGhostCount == 9 {
                            self.ownGhostCount = 0
                            self.logEvent("Ghost expired")
                            self.removeActiveItemImageView(12)
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    
            //get inflicted with reach
                    if globalIsOffense == true && Int("\(self.offenseInbox3[0] as! Int)") == 13 && self.reachNonce != Int("\(self.offenseInbox3[1] as! Int)") {
                        self.reachNonce = Int("\(self.offenseInbox3[1] as! Int)")!
                        self.reachPlayer = Int("\(self.offenseInbox3[2] as! Int)")!
                        self.reachCount = 1
                    }
                    if self.reachCount > 0 {
                        self.reachCount++
                        if self.reachCount == 9 {
                            self.reachCount = 0
                            self.reachPlayer = 0
                        }
                    }
                
            //timer, to indicate to reach owner when it expires
                    if self.ownReachCount > 0 {
                        self.ownReachCount++
                        if self.ownReachCount == 9 {
                            self.ownReachCount = 0
                            self.logEvent("Reach expired")
                            self.removeActiveItemImageView(13)
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                    }
                    
                    
            //get tagged by sickle
                    if localPlayerPosition == "offense1" && Int("\(self.offense1Inbox[0] as! Int)") == 15 && self.sickleNonce != Int("\(self.offense1Inbox[2] as! Int)")  {
                        self.sickleNonce = Int("\(self.offense1Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense1Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        if localPlayerStatus == 1 {
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 3, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "sickle")
                        }
                    }
                    if localPlayerPosition == "offense2" && Int("\(self.offense2Inbox[0] as! Int)") == 15 && self.sickleNonce != Int("\(self.offense2Inbox[2] as! Int)") {
                        self.sickleNonce = Int("\(self.offense2Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense2Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        if localPlayerStatus == 1 {
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 3, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "sickle")
                        }
                    }
                    if localPlayerPosition == "offense3" && Int("\(self.offense3Inbox[0] as! Int)") == 15 && self.sickleNonce != Int("\(self.offense3Inbox[2] as! Int)") {
                        self.sickleNonce = Int("\(self.offense3Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense3Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        if localPlayerStatus == 1 {
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 3, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "sickle")
                        }
                    }
                    if localPlayerPosition == "offense4" && Int("\(self.offense4Inbox[0] as! Int)") == 15 && self.sickleNonce != Int("\(self.offense4Inbox[2] as! Int)") {
                        self.sickleNonce = Int("\(self.offense4Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense4Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        if localPlayerStatus == 1 {
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 3, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "sickle")
                        }
                    }
                    if localPlayerPosition == "offense5" && Int("\(self.offense5Inbox[0] as! Int)") == 15 && self.sickleNonce != Int("\(self.offense5Inbox[2] as! Int)") {
                        self.sickleNonce = Int("\(self.offense5Inbox[2] as! Int)")!
                        let taggedByTemp = self.offense5Inbox[1] as! String
                        let nonceTemp = Int(arc4random_uniform(999999))
                        if localPlayerStatus == 1 {
                        self.postTag(taggedByTemp, tagee: globalUserName, method: 3, nonce: nonceTemp, hadFlag: self.localPlayerCapturedPoint)
                        self.tagLocalPlayerByItem(taggedByTemp, item: "sickle")
                        }
                    }
                    
            //get tagged by lighting
                    if globalIsOffense == true && Int("\(self.offenseInbox[0] as! Int)") == 16 && self.lightningNonce != Int("\(self.offenseInbox[1] as! Int)") {
                    self.lightningNonce = Int("\(self.offenseInbox[1] as! Int)")!
                        if localPlayerStatus == 1 {
                        let taggedByTemp = self.offenseInbox[2] as! String
                        self.tagLocalPlayerByItem(taggedByTemp, item: "lightning")
                        }
                    }
                    
//                    //trigger mine (tagging opponents), if applicable
//                    if globalIsOffense == true {
//                        //mine 1
//                        if self.mine1Dropped == true {
//                            if self.mine1region.containsCoordinate(self.defense1Coordinates) || self.mine1region.containsCoordinate(self.defense2Coordinates) || self.mine1region.containsCoordinate(self.defense3Coordinates) || self.mine1region.containsCoordinate(self.defense4Coordinates) || self.mine1region.containsCoordinate(self.defense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                
//                                if self.mine1region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense1Inbox")
//                                    playerTaggedByMine = defense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense2Inbox")
//                                    playerTaggedByMine = defense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense3Inbox")
//                                    playerTaggedByMine = defense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense4Inbox")
//                                    playerTaggedByMine = defense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense5Inbox")
//                                    playerTaggedByMine = defense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine1Dropped = false
//                                
//                                if self.mine1isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine1DropPin)
//                                }
//                                if self.mine1isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine1DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine1Circle)
//                                self.unpostMine(self.mine1Nonce)
//                            }
//                        }
//                        //mine2
//                        if self.mine2Dropped == true {
//                            if self.mine2region.containsCoordinate(self.defense1Coordinates) || self.mine2region.containsCoordinate(self.defense2Coordinates) || self.mine2region.containsCoordinate(self.defense3Coordinates) || self.mine2region.containsCoordinate(self.defense4Coordinates) || self.mine2region.containsCoordinate(self.defense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                if self.mine2region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense1Inbox")
//                                    playerTaggedByMine = defense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense2Inbox")
//                                    playerTaggedByMine = defense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense3Inbox")
//                                    playerTaggedByMine = defense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense4Inbox")
//                                    playerTaggedByMine = defense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense5Inbox")
//                                    playerTaggedByMine = defense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine2Dropped = false
//                                
//                                if self.mine2isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine2DropPin)
//                                }
//                                if self.mine2isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine2DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine2Circle)
//                                self.unpostMine(self.mine2Nonce)
//                            }
//                        }
//                        //mine3
//                        if self.mine3Dropped == true {
//                            if self.mine3region.containsCoordinate(self.defense1Coordinates) || self.mine3region.containsCoordinate(self.defense2Coordinates) || self.mine3region.containsCoordinate(self.defense3Coordinates) || self.mine3region.containsCoordinate(self.defense4Coordinates) || self.mine3region.containsCoordinate(self.defense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                if self.mine3region.containsCoordinate(self.defense1Coordinates) && defense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense1Inbox")
//                                    playerTaggedByMine = defense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.defense2Coordinates) && defense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense2Inbox")
//                                    playerTaggedByMine = defense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.defense3Coordinates) && defense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense3Inbox")
//                                    playerTaggedByMine = defense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.defense4Coordinates) && defense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense4Inbox")
//                                    playerTaggedByMine = defense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.defense5Coordinates) && defense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "defense5Inbox")
//                                    playerTaggedByMine = defense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine3Dropped = false
//                                
//                                if self.mine3isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine3DropPin)
//                                }
//                                if self.mine3isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine3DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine3Circle)
//                                self.unpostMine(self.mine3Nonce)
//                            }
//                        }
//                    }
//                    if globalIsOffense == false {
//                        
//                        //mine 1
//                        if self.mine1Dropped == true {
//                            if self.mine1region.containsCoordinate(self.offense1Coordinates) || self.mine1region.containsCoordinate(self.offense2Coordinates) || self.mine1region.containsCoordinate(self.offense3Coordinates) || self.mine1region.containsCoordinate(self.offense4Coordinates) || self.mine1region.containsCoordinate(self.offense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                if self.mine1region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense1Inbox")
//                                    playerTaggedByMine = offense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense2Inbox")
//                                    playerTaggedByMine = offense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense3Inbox")
//                                    playerTaggedByMine = offense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense4Inbox")
//                                    playerTaggedByMine = offense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine1region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense5Inbox")
//                                    playerTaggedByMine = offense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine1Dropped = false
//                                
//                                if self.mine1isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine1DropPin)
//                                }
//                                if self.mine1isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine1DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine1Circle)
//                                self.unpostMine(self.mine1Nonce)
//                            }
//                        }
//                        //mine2
//                        if self.mine2Dropped == true {
//                            if self.mine2region.containsCoordinate(self.offense1Coordinates) || self.mine2region.containsCoordinate(self.offense2Coordinates) || self.mine2region.containsCoordinate(self.offense3Coordinates) || self.mine2region.containsCoordinate(self.offense4Coordinates) || self.mine2region.containsCoordinate(self.offense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                if self.mine2region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense1Inbox")
//                                    playerTaggedByMine = offense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense2Inbox")
//                                    playerTaggedByMine = offense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense3Inbox")
//                                    playerTaggedByMine = offense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense4Inbox")
//                                    playerTaggedByMine = offense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine2region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense5Inbox")
//                                    playerTaggedByMine = offense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine2Dropped = false
//                                
//                                if self.mine2isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine2DropPin)
//                                }
//                                if self.mine2isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine2DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine2Circle)
//                                self.unpostMine(self.mine2Nonce)
//                            }
//                        }
//                        //mine3
//                        if self.mine3Dropped == true {
//                            if self.mine3region.containsCoordinate(self.offense1Coordinates) || self.mine3region.containsCoordinate(self.offense2Coordinates) || self.mine3region.containsCoordinate(self.offense3Coordinates) || self.mine3region.containsCoordinate(self.offense4Coordinates) || self.mine3region.containsCoordinate(self.offense5Coordinates) {
//                                
//                                var playerTaggedByMine = ""
//                                var playersTaggedByMine = 0
//                                if self.mine3region.containsCoordinate(self.offense1Coordinates) && offense1Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense1Inbox")
//                                    playerTaggedByMine = offense1var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.offense2Coordinates) && offense2Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense2Inbox")
//                                    playerTaggedByMine = offense2var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.offense3Coordinates) && offense3Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense3Inbox")
//                                    playerTaggedByMine = offense3var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.offense4Coordinates) && offense4Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense4Inbox")
//                                    playerTaggedByMine = offense4var
//                                    playersTaggedByMine++
//                                }
//                                if self.mine3region.containsCoordinate(self.offense5Coordinates) && offense5Status == 1 {
//                                    self.postMineTag(globalUserName,inbox: "offense5Inbox")
//                                    playerTaggedByMine = offense5var
//                                    playersTaggedByMine++
//                                }
//                                
//                                if playersTaggedByMine > 1 {
//                                    self.logEvent("Mine triggered on \(playersTaggedByMine) opponents!")
//                                }
//                                else if playersTaggedByMine == 1 {
//                                    self.logEvent("Mine triggered on \(playerTaggedByMine)")
//                                }
//                                else if playersTaggedByMine == 0 {
//                                    self.logEvent("Mine tripped by tagged player!")
//                                }
//                                
//                                self.mine3Dropped = false
//                                
//                                if self.mine3isSuper == false {
//                                    self.mapView.removeAnnotation(self.mine3DropPin)
//                                }
//                                if self.mine3isSuper == true {
//                                    self.mapView.removeAnnotation(self.supermine3DropPin)
//                                }
//                                self.mapView.removeOverlay(self.mine3Circle)
//                                self.unpostMine(self.mine3Nonce)
//                            }
//                        }
//                        
//                    }
                    
                    self.unmapItems()
                    self.itemTimerCount = 7
//                    self.itemInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
//                        if error == nil {
//                            print("item timer set")
//                            self.unmapItems()
//                            print("itemtimer a: \(self.itemTimerCount)")
//                            self.itemTimerCount = 7
//                            print("itemtimer b: \(self.itemTimerCount)")
//                        }
//                        else {
//                            self.unmapItems()
//                            print("itemtimer c: \(self.itemTimerCount)")
//                            self.itemTimerCount = 7
//                            print("itemtimer d: \(self.itemTimerCount)")
//                            
//                        }
//                    }
                }
                else {
                    self.unmapItems()
                    self.itemTimerCount = 7
                    print("itemtimer f: \(self.itemTimerCount)")
                }
        }
    }
}

//timer sync system timer
    func timerSyncSystemTimerUpdate() {
        if(self.timerSyncSystemTimerCount > 0)
        {
            self.timerSyncSystemTimerCount--
        }
        if(self.timerSyncSystemTimerCount == 0)
        {
            
        //update the time sync field, for others to use
            if localPlayerPosition == "offense1" {
                inGameInfo.fetchInBackgroundWithBlock  {
                    (inGameInfo: PFObject?, error: NSError?) -> Void in
                    //2-1 changed from:   if error == nil
                    if let inGameInfo = inGameInfo {
                        inGameInfo["timerSyncValue"] = Int(gameTimerCount)
                        let date = NSDate()
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "ss"
                        let secondsInt = dateFormatter.stringFromDate(date)
                        inGameInfo["secondsSyncInt"] = Int(secondsInt)
                        inGameInfo.saveEventually()
                        self.timerSyncSystemTimerCount = 15
                    }
                    else {
                        self.timerSyncSystemTimerCount = 15
                    }
                }
            }
            
        //all others- consume the new system time and update
            if localPlayerPosition != "offense1" {
                
                inGameInfo.fetchInBackgroundWithBlock  {
                    (inGameInfo: PFObject?, error: NSError?) -> Void in
                    //2-1 changed from:   if error == nil
                    if let inGameInfo = inGameInfo {
                        self.timerSyncValue = inGameInfo.objectForKey("timerSyncValue") as! Int
                        self.secondsSyncInt = inGameInfo.objectForKey("secondsSyncInt") as! Int
                        if self.timerSyncValue != self.timerSyncValueLast  && self.timerSyncValue > 0 {
                    //reset timer to synchronize with offense1
                            let date = NSDate()
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "ss"
                            let secondsInt = Int(dateFormatter.stringFromDate(date))
                            
                            let candidateA = self.timerSyncValue - (secondsInt! - self.secondsSyncInt)
                            let candidateB = self.timerSyncValue - ((secondsInt! + 60) - self.secondsSyncInt)
                            
                            if secondsInt >= self.secondsSyncInt {
                                gameTimerCount = candidateA
                            }
                            
                            if secondsInt < self.secondsSyncInt {
                                gameTimerCount = candidateB
                            }
                            
                            
                        }
                        self.timerSyncValueLast = self.timerSyncValue
                        self.timerSyncSystemTimerCount = 15
                    }
                    else {
                        self.timerSyncSystemTimerCount = 15
                    }
                }
                
                
            }
            
       
        }
        
    }
    
    
    
// error/anomaly correction system timer
    func errorCorrectionSystemTimerUpdate() {
        if(self.errorCorrectionSystemTimerCount > 0)
        {
            self.errorCorrectionSystemTimerCount--
        }
        if(self.errorCorrectionSystemTimerCount == 0) && self.errorCorrectionSystemTimerReset == true
        {
            print("error correction system timer fired")
            
            self.errorCorrectionSystemTimerReset = false
            
        //run error correction detection/correction code
            if (playerCapturedPoint != "n" && self.localPlayerCapturedPoint == false) || (self.playerCapturingPoint != "n" && self.localPlayerCapturingPoint == false)  {
                
                inGameInfo.fetchInBackgroundWithBlock {
                    (inGameInfo: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        self.errorCorrectionSystemTimerCount = 10
                        self.errorCorrectionSystemTimerReset = true
                    }
                    else if let inGameInfo = inGameInfo {
                        //check for capturING point
                        let playerCapturingPointHeartbeatParseCloneTemp = inGameInfo.objectForKey("playerCapturingPointHeartbeat") as! String
                        if playerCapturingPointHeartbeatParseCloneTemp == self.playerCapturingPointHeartbeatParseClone && self.playerCapturingPoint != "n" {
                            self.playerCapturingPointErrorsLogged++
                        }
                        else {
                            self.playerCapturingPointErrorsLogged == 0
                        }
                        self.playerCapturingPointHeartbeatParseClone = playerCapturingPointHeartbeatParseCloneTemp
                        
                        //check for capturED point
                        let playerCapturedPointHeartbeatParseCloneTemp = inGameInfo.objectForKey("playerCapturedPointHeartbeat") as! String
                        if playerCapturedPointHeartbeatParseCloneTemp == self.playerCapturedPointHeartbeatParseClone  && playerCapturedPoint != "n" {
                            self.playerCapturedPointErrorsLogged++
                            print("player capture error logged - blash")
                        }
                        else {
                            self.playerCapturedPointErrorsLogged == 0
                            print("reset playercapturedpointerroslogged to zero")
                        }
                        self.playerCapturedPointHeartbeatParseClone = playerCapturedPointHeartbeatParseCloneTemp
                        
                    //reset variables if error threshold exceeded
                    if self.playerCapturingPointErrorsLogged >= 3 || self.playerCapturedPointErrorsLogged >= 3 {
                    
                        //if a threshold of errors in succession is exceeded, reset parse flag variables - capturING
                        if self.playerCapturingPointErrorsLogged >= 3 {
                        print("error correction timer fired - capturing ")
                        self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
                        inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
                        inGameInfo["playerWithPointTaggedName"] = "Corrected error"
                        inGameInfo["playerCapturingPoint"] = "n"
                        inGameInfo["playerCapturingPointPosition"] = "n"
                    }
                    
                        //if a threshold of errors in succession is exceeded, reset parse flag variables - capturED
                        if self.playerCapturedPointErrorsLogged >= 3 {
                        print("error corrector - capturED flag fired")
                        inGameInfo["playerCapturingPoint"] = "n"
                        inGameInfo["playerCapturedPoint"] = "n"
                        inGameInfo["playerCapturingPointPosition"] = "n"
                        inGameInfo["playerCapturedPointPosition"] = "n"
                        }

                    inGameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.networkFailedCount = 0
                                self.errorCorrectionSystemTimerCount = 10
                                self.errorCorrectionSystemTimerReset = true
                                self.logEvent("Player w/ flag droped - reset flag")
                                    if self.playerCapturingPointErrorsLogged >= 3 {
                                        self.playerCapturingPointErrorsLogged = 0
                                        print("player capturing point errors logged reset")
                                    }
                                    if self.playerCapturedPointErrorsLogged >= 3 {
                                        self.playerCapturedPointErrorsLogged = 0
                                        print("player capturing point errors logged reset")
                                    }
                            }
                            else {
                                self.errorCorrectionSystemTimerCount = 10
                                self.errorCorrectionSystemTimerReset = true
                                self.networkFailedCount++
                                inGameInfo.saveEventually()
                            }
                        }
                        
                    }
                    else {
                        self.errorCorrectionSystemTimerCount = 10
                        self.errorCorrectionSystemTimerReset = true
                        }
                        
                }
                    else {
                        self.errorCorrectionSystemTimerCount = 10
                        self.errorCorrectionSystemTimerReset = true
                    }
                    
            }
    
        }
            
            else {
                self.errorCorrectionSystemTimerCount = 10
                self.errorCorrectionSystemTimerReset = true
            }
        }
    }

    
//capture timer
func captureTimerUpdate() {
    if(captureTimerCount > 0)
        {
        captureTimerCount--
        eventsLabel.text = "Capturing... \(String(captureTimerCount))"
        }
    if(captureTimerCount == 0)
        {
        
        //set negative so only fires once
            captureTimerCount = -1
            
       //point capture event!
            if self.localPlayerCapturingPoint == true  && localPlayerStatus == 1 {
                self.localPlayerCapturingPoint = false
                
            inGameInfo.fetchInBackgroundWithBlock {
                (inGameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.eventsLabel.text = "Network error - try again"
                }
                    
                else if let inGameInfo = inGameInfo {
                    let playerCapturedPoint2: String = inGameInfo.objectForKey("playerCapturedPoint") as! String
                    if playerCapturedPoint2 == "n"  && localPlayerStatus == 1 {
                        inGameInfo["playerCapturingPoint"] = "n"
                        inGameInfo["playerCapturedPoint"] = globalUserName
                        inGameInfo["playerCapturedPointPosition"] = localPlayerPosition
                        self.postPlayerCapturedPointHeartbeat = String(arc4random_uniform(999999))
                        inGameInfo["playerCapturingPointHeartbeat"] = self.postPlayerCapturingPointHeartbeat
                        
                                inGameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                                    if error == nil && localPlayerStatus == 1 {

                                self.localPlayerCapturedPoint = true
                                    self.flagImageView.hidden = false
                                self.logEvent("Captured the flag! Get back to base")
                                        self.mapView.removeAnnotation(self.pointDropPin)
                                        self.mapView.removeAnnotation(self.pointdroptemp)
                                        self.flagAnnotationHidden = true
                                self.captureTimer.invalidate()
                                self.logicCapturing2?.stop()
                                self.logicCapturing2?.currentTime = 0
                                
                                        self.logicCapture?.play()
                                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                        
                                //double check (in case playerCapturedPoint not updated in parse )
                                        inGameInfo.fetchInBackgroundWithBlock {
                                            (inGameInfo: PFObject?, error: NSError?) -> Void in
                                            if let inGameInfo = inGameInfo {
                                            //2-1 changed from if error == nil
                                            if localPlayerStatus == 1 {
                                                let playerCapturedPointTemp = self.inGameInfo.objectForKey("playerCapturedPoint") as! String
                                                if playerCapturedPointTemp != globalUserName && localPlayerStatus == 1 {
                                                print("secondary playerCapturedPoint post update fired")
                                                inGameInfo["playerCapturingPoint"] = "n"
                                                inGameInfo["playerCapturedPoint"] = globalUserName
                                                inGameInfo["playerCapturedPointPosition"] = localPlayerPosition
                                                inGameInfo.saveEventually()
                                                }
                                            }
                                        }
                                        }
                                        
                                    }
                                    else if error != nil {
                                        self.eventsLabel.text = "Error A2"
                                    }
                                }
//                            }
//                            else {
//                                self.localPlayerCapturedPoint = true
//                                self.flagImageView.hidden = false
//                                self.logEvent("Captured the flag! Get back to base")
//                                    self.mapView.removeAnnotation(self.pointDropPin)
//                                    self.mapView.removeAnnotation(self.pointdroptemp)
//                                    self.flagAnnotationHidden = true
//                                self.captureTimer.invalidate()
//                                self.logicCapturing2?.stop()
//                                
//                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                                self.logicCapture?.play()
//                            }
//                        }
                    }
                    else {
                         self.eventsLabel.text = "Error A1"
                    }
                
                }
                
            }
            
        }
            //just in case there's an error, invalidate
            self.captureTimer.invalidate()
        }
    }

    
//overlay clear timer
    func overlayTimerUpdate() {
        if(overlayTimerCount > 0)
        {
            overlayTimerCount++
        }
        if(overlayTimerCount == 5)
        {
            self.mapView.removeAnnotation(self.superbombDropPin)
            self.mapView.removeAnnotation(self.bombDropPin)
            self.mapView.removeAnnotation(self.scanDropPin)
            self.overlayTimerCount = 0
            self.overlayTimer.invalidate()
        }
    }
    
    
//tag timer
    func tagTimerUpdate() {
        if(self.tagTimerCount > 0)
        {
            self.tagTimerCount++
        print("tag timer count \(self.tagTimerCount)")
        }
        if(self.tagTimerCount == 2 || self.tagTimerCount == 4 || self.tagTimerCount == 6 || self.tagTimerCount == 8)
        {
            print("tag timer A")
            if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            }
            else if globalIsOffense == false {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            }
            if self.tagTimerCount == 6 {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        if(self.tagTimerCount == 3 || self.tagTimerCount == 5 || self.tagTimerCount == 7 || self.tagTimerCount == 9)
        {
            print("tag timer A")
            if globalIsOffense == true {
            self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
            }
            else {
                self.view.backgroundColor = UIColor(red:0.902,green:0.659,blue:0.651,alpha:1.0)
            }
        }
        if(tagTimerCount == 10)
        {
            self.tagTimerCount = 0
            self.tagTimer.invalidate()
        }
    }
    
    
//defense recharge timer
    func defenseRechargeTimerUpdate() {
        if(defenseRechargeTimerCount > 0)
        {
            defenseRechargeTimerCount--
            eventsLabel.text = "Recharging... \(String(defenseRechargeTimerCount))"
        }
        if(defenseRechargeTimerCount == 0)
        {
            localPlayerStatus = 1
            
            //set the alert icon and label
            if playerCapturedPoint == "n" {
                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                self.iconLabel.text = "Flag in place"
            }
            if playerCapturedPoint != "n" {
                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                self.iconLabel.text = "Flag captured!"
            }
            //start broadcasting beacon
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
            
            self.defenseRechargeTimer.invalidate()
            self.defenseRechargeTimerCount = -1
            eventsLabel.text = "Recharged!"
        }
    }

    
//OFFENSE system timer (runs code every 5 seconds)
    func offenseSystemTimerUpdate() {
        
        if(offenseSystemTimerCount > 0)
        {
            offenseSystemTimerCount--
        }
        if(offenseSystemTimerCount == 0)
        {
            if bluetoothOn == false  && localPlayerStatus == 1 {
//                self.tagLocalPlayerByItem("na", item: "bluetooth")
            }
            
            if self.networkFailedCount == 6 {
                self.networkFailedCount = 0
                self.tagLocalPlayerByItem("na", item: "network")
            }
            
            if localPlayerStatus == 1 {
                self.alertIconImageView.hidden = true
                self.iconLabel.hidden = true
                self.lifeMeterImageView.hidden = false
            }
            else if localPlayerStatus == 0 {
                self.flagImageView.hidden = true
                self.lifeMeterImageView.image = UIImage(named:"0life.png")
            }
            
            if self.flagNotInBaseCount != 0 {
                self.flagNotInBaseCount++
                if self.flagNotInBaseCount == 10 {
                    self.flagNotInBaseCount = 0
                }
            }
            
            inGameInfo.fetchInBackgroundWithBlock {
                (inGameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.offenseSystemTimerCount = 2
                    print("offense timer reset - d")
                }
                else if let inGameInfo = inGameInfo {
                    
        //upload geo data and status
            inGameInfo["\(localPlayerPosition)Lat"] = self.currentLatitude
            inGameInfo["\(localPlayerPosition)Long"] = self.currentLongitude
            inGameInfo["\(localPlayerPosition)Status"] = localPlayerStatus
                    
        //update flag capture vars
            self.playerCapturingPoint = inGameInfo.objectForKey("playerCapturingPoint") as! String
                
            playerCapturedPointPosition = inGameInfo.objectForKey("playerCapturedPointPosition") as! String
                    
                    
        //update teammates' locations on map, and statuses
            if inGameInfo.objectForKey("offense1Lat") != nil  && localPlayerPosition != "offense1"  {
                self.offense1Lat = inGameInfo.objectForKey("offense1Lat") as! Double
                self.offense1Long = inGameInfo.objectForKey("offense1Long") as! Double
                self.offense1Coordinates = CLLocationCoordinate2D(latitude: self.offense1Lat, longitude: self.offense1Long)
                self.mapView.removeAnnotation(self.offense1DropPin)
                self.mapView.removeAnnotation(self.offense1XDropPin)
                self.mapView.removeAnnotation(self.offense1flagDropPin)
                offense1Status = inGameInfo.objectForKey("offense1Status") as! Int
                
                if playerCapturedPointPosition == "offense1" {
                    self.offense1flagDropPin.coordinate = self.offense1Coordinates
                    self.offense1flagDropPin.title = String(offense1var)
                    self.mapView.addAnnotation(self.offense1flagDropPin)
                }
                else if offense1Status == 0 {
                    self.offense1XDropPin.coordinate = self.offense1Coordinates
                    self.offense1XDropPin.title = String(offense1var)
                    self.mapView.addAnnotation(self.offense1XDropPin)
                }
                else {
                    self.offense1DropPin.coordinate = self.offense1Coordinates
                    self.offense1DropPin.title = String(offense1var)
                    self.mapView.addAnnotation(self.offense1DropPin)
                }
                    }
                    
                    if inGameInfo.objectForKey("offense2Lat") != nil  && localPlayerPosition != "offense2"  {
                        self.offense2Lat = inGameInfo.objectForKey("offense2Lat") as! Double
                        self.offense2Long = inGameInfo.objectForKey("offense2Long") as! Double
                        self.offense2Coordinates = CLLocationCoordinate2D(latitude: self.offense2Lat, longitude: self.offense2Long)
                        self.mapView.removeAnnotation(self.offense2DropPin)
                        self.mapView.removeAnnotation(self.offense2XDropPin)
                        self.mapView.removeAnnotation(self.offense2flagDropPin)
                        offense2Status = inGameInfo.objectForKey("offense2Status") as! Int
                        
                        if playerCapturedPointPosition == "offense2" {
                            self.offense2flagDropPin.coordinate = self.offense2Coordinates
                            self.offense2flagDropPin.title = String(offense2var)
                            self.mapView.addAnnotation(self.offense2flagDropPin)
                        }
                        else if offense2Status == 0 {
                            self.offense2XDropPin.coordinate = self.offense2Coordinates
                            self.offense2XDropPin.title = String(offense2var)
                            self.mapView.addAnnotation(self.offense2XDropPin)
                        }
                        else {
                            self.offense2DropPin.coordinate = self.offense2Coordinates
                            self.offense2DropPin.title = String(offense2var)
                            self.mapView.addAnnotation(self.offense2DropPin)
                        }
                    }
                    
                    if inGameInfo.objectForKey("offense3Lat") != nil  && localPlayerPosition != "offense3"  {
                        self.offense3Lat = inGameInfo.objectForKey("offense3Lat") as! Double
                        self.offense3Long = inGameInfo.objectForKey("offense3Long") as! Double
                        self.offense3Coordinates = CLLocationCoordinate2D(latitude: self.offense3Lat, longitude: self.offense3Long)
                        self.mapView.removeAnnotation(self.offense3DropPin)
                        self.mapView.removeAnnotation(self.offense3XDropPin)
                        self.mapView.removeAnnotation(self.offense3flagDropPin)
                        offense3Status = inGameInfo.objectForKey("offense3Status") as! Int
                        
                        if playerCapturedPointPosition == "offense3" {
                            self.offense3flagDropPin.coordinate = self.offense3Coordinates
                            self.offense3flagDropPin.title = String(offense3var)
                            self.mapView.addAnnotation(self.offense3flagDropPin)
                        }
                        else if offense3Status == 0 {
                            self.offense3XDropPin.coordinate = self.offense3Coordinates
                            self.offense3XDropPin.title = String(offense3var)
                            self.mapView.addAnnotation(self.offense3XDropPin)
                        }
                        else {
                            self.offense3DropPin.coordinate = self.offense3Coordinates
                            self.offense3DropPin.title = String(offense3var)
                            self.mapView.addAnnotation(self.offense3DropPin)
                        }
                    }
                    
                    if inGameInfo.objectForKey("offense4Lat") != nil  && localPlayerPosition != "offense4"  {
                        self.offense4Lat = inGameInfo.objectForKey("offense4Lat") as! Double
                        self.offense4Long = inGameInfo.objectForKey("offense4Long") as! Double
                        self.offense4Coordinates = CLLocationCoordinate2D(latitude: self.offense4Lat, longitude: self.offense4Long)
                        self.mapView.removeAnnotation(self.offense4DropPin)
                        self.mapView.removeAnnotation(self.offense4XDropPin)
                        self.mapView.removeAnnotation(self.offense4flagDropPin)
                        offense4Status = inGameInfo.objectForKey("offense4Status") as! Int
                        
                        if playerCapturedPointPosition == "offense4" {
                            self.offense4flagDropPin.coordinate = self.offense4Coordinates
                            self.offense4flagDropPin.title = String(offense4var)
                            self.mapView.addAnnotation(self.offense4flagDropPin)
                        }
                        else if offense4Status == 0 {
                            self.offense4XDropPin.coordinate = self.offense4Coordinates
                            self.offense4XDropPin.title = String(offense4var)
                            self.mapView.addAnnotation(self.offense4XDropPin)
                        }
                        else {
                            self.offense4DropPin.coordinate = self.offense4Coordinates
                            self.offense4DropPin.title = String(offense4var)
                            self.mapView.addAnnotation(self.offense4DropPin)
                        }
                    }
                    
                    if inGameInfo.objectForKey("offense5Lat") != nil  && localPlayerPosition != "offense5"  {
                        self.offense5Lat = inGameInfo.objectForKey("offense5Lat") as! Double
                        self.offense5Long = inGameInfo.objectForKey("offense5Long") as! Double
                        self.offense5Coordinates = CLLocationCoordinate2D(latitude: self.offense5Lat, longitude: self.offense5Long)
                        self.mapView.removeAnnotation(self.offense5DropPin)
                        self.mapView.removeAnnotation(self.offense5XDropPin)
                        self.mapView.removeAnnotation(self.offense5flagDropPin)
                        offense5Status = inGameInfo.objectForKey("offense5Status") as! Int
                        
                        if playerCapturedPointPosition == "offense5" {
                            self.offense5flagDropPin.coordinate = self.offense5Coordinates
                            self.offense5flagDropPin.title = String(offense5var)
                            self.mapView.addAnnotation(self.offense5flagDropPin)
                        }
                        else if offense5Status == 0 {
                            self.offense5XDropPin.coordinate = self.offense5Coordinates
                            self.offense5XDropPin.title = String(offense5var)
                            self.mapView.addAnnotation(self.offense5XDropPin)
                        }
                        else {
                            self.offense5DropPin.coordinate = self.offense5Coordinates
                            self.offense5DropPin.title = String(offense5var)
                            self.mapView.addAnnotation(self.offense5DropPin)
                        }
                    }

       
       //update opponents' locations (for scan etc), but don't display, and get status
            if inGameInfo.objectForKey("defense1Lat") != nil  {
                self.defense1Lat = inGameInfo.objectForKey("defense1Lat") as! Double
                self.defense1Long = inGameInfo.objectForKey("defense1Long") as! Double
                self.defense1Coordinates = CLLocationCoordinate2D(latitude: self.defense1Lat, longitude: self.defense1Long)
                self.defense1DropPin.coordinate = self.defense1Coordinates
                self.defense1XDropPin.coordinate = self.defense1Coordinates
                self.defense1DropPin.title = String(defense1var)
                self.defense1XDropPin.title = String(defense1var)
                defense1Status = inGameInfo.objectForKey("defense1Status") as! Int
                    }
            if inGameInfo.objectForKey("defense2Lat") != nil  {
                self.defense2Lat = inGameInfo.objectForKey("defense2Lat") as! Double
                self.defense2Long = inGameInfo.objectForKey("defense2Long") as! Double
                self.defense2Coordinates = CLLocationCoordinate2D(latitude: self.defense2Lat, longitude: self.defense2Long)
                self.defense2DropPin.coordinate = self.defense2Coordinates
                self.defense2XDropPin.coordinate = self.defense2Coordinates
                self.defense2DropPin.title = String(defense2var)
                self.defense2XDropPin.title = String(defense2var)
                defense2Status = inGameInfo.objectForKey("defense2Status") as! Int
                    }
            if inGameInfo.objectForKey("defense3Lat") != nil  {
                self.defense3Lat = inGameInfo.objectForKey("defense3Lat") as! Double
                self.defense3Long = inGameInfo.objectForKey("defense3Long") as! Double
                self.defense3Coordinates = CLLocationCoordinate2D(latitude: self.defense3Lat, longitude: self.defense3Long)
                self.defense3DropPin.coordinate = self.defense3Coordinates
                self.defense3XDropPin.coordinate = self.defense3Coordinates
                self.defense3DropPin.title = String(defense3var)
                self.defense3XDropPin.title = String(defense3var)
                defense3Status = inGameInfo.objectForKey("defense3Status") as! Int
                    }
            if inGameInfo.objectForKey("defense4Lat") != nil  {
                self.defense4Lat = inGameInfo.objectForKey("defense4Lat") as! Double
                self.defense4Long = inGameInfo.objectForKey("defense4Long") as! Double
                self.defense4Coordinates = CLLocationCoordinate2D(latitude: self.defense4Lat, longitude: self.defense4Long)
                self.defense4DropPin.coordinate = self.defense4Coordinates
                self.defense4XDropPin.coordinate = self.defense4Coordinates
                self.defense4DropPin.title = String(defense4var)
                self.defense4XDropPin.title = String(defense4var)
                defense4Status = inGameInfo.objectForKey("defense4Status") as! Int
                    }
            if inGameInfo.objectForKey("defense5Lat") != nil  {
                self.defense5Lat = inGameInfo.objectForKey("defense5Lat") as! Double
                self.defense5Long = inGameInfo.objectForKey("defense5Long") as! Double
                self.defense5Coordinates = CLLocationCoordinate2D(latitude: self.defense5Lat, longitude: self.defense5Long)
                self.defense5DropPin.coordinate = self.defense5Coordinates
                self.defense5XDropPin.coordinate = self.defense5Coordinates
                self.defense5DropPin.title = String(defense5var)
                self.defense5XDropPin.title = String(defense5var)
                defense5Status = inGameInfo.objectForKey("defense5Status") as! Int
                    }
                    
                    
    //DETERMINE WHETHER THE PLAYER IS IN THE OFFENSE BASE REGION, IF SO, FLIP BIT AND FIRE EVENTS
                    let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
                        if self.baseRegion.containsCoordinate(currentCoordinate) {
                            self.localPlayerRegion = 1
                      
                            //offense player enters their base at beginning of game to "power up", or tagged offense player enters base to power up
                            if globalIsOffense == true && (localPlayerStatus == 2 || localPlayerStatus == 0) {
                                localPlayerStatus = 1

                                self.alertIconImageView.hidden = true
                                self.iconLabel.hidden = true
                                self.lifeMeterImageView.hidden = false
                                self.lifeMeterImageView.image = UIImage(named:"5life.png")
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.logicPowerUp?.play()
                            }
                            

                            //offense player enters their base with the point, win game
                            if localPlayerStatus == 1 && self.localPlayerCapturedPoint == true {
                                self.localPlayerWonGame = true
                                inGameInfo["gameWinner"] = globalUserName
                            }
 
                    }

    
    //DETERMINE WHETHER THE PLAYER IS IN THE CURRENT POINT REGION, IF SO, FLIP BIT AND FIRE EVENTS
            if self.pointRegion.containsCoordinate(currentCoordinate) == true {
                self.localPlayerRegion = 2
                
                
                //untagged offense player enters point region, start capture timer if nobody else is capturing
                let playerCapturingPoint2: String = inGameInfo.objectForKey("playerCapturingPoint") as! String
                let playerCapturedPoint2: String = inGameInfo.objectForKey("playerCapturedPoint") as! String
        
                    if localPlayerStatus == 1 && self.localPlayerCapturingPoint == false && self.localPlayerCapturedPoint == false {
        
                        if playerCapturingPoint2 == "n" && playerCapturedPoint2 == "n" {
                            
                            let rand: String = String(arc4random_uniform(999999))
                            inGameInfo["randomPlayerCapturingPoint"] = rand
                            inGameInfo["playerCapturingPoint"] = globalUserName
                            
                        //added below (capturing event), and commented out save commands in this block
                            self.localPlayerCapturingPoint = true
                            self.localPlayerCapturedPoint = false
                            self.flagImageView.hidden = true
                            self.captureTimerCount = self.captureTime
                            self.captureTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("captureTimerUpdate"), userInfo: nil, repeats: true)
                            self.captureTimer.tolerance = 0.2
                            
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.logicCapturing2?.play()
                            
                        }
                    //notify that somebody else is capturing the point
                        else if (playerCapturingPoint2 != "n" || playerCapturedPoint2 != "n") && playerCapturingPoint2 != globalUserName && playerCapturedPoint2 != globalUserName && self.localPlayerCapturingPoint == false && self.localPlayerCapturedPoint == false && self.flagNotInBaseCount == 0 {
                            self.flagNotInBaseCount++
                            
                            self.logEvent("Flag not in base..")
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.logicReign?.play()
                        }
                        
                    }
                }
   
    //IF PLAYER LEAVES POINT REGION WHILE CAPTURING THE FLAG, CANCEL CAPTURE TIMER
            else if self.pointRegion.containsCoordinate(currentCoordinate) == false {
                        self.localPlayerRegion = 0
                        self.captureTimer.invalidate()
                        self.logicCapturing2?.stop()
                        self.logicCapturing2?.currentTime = 0
                        
                        //if player capturing point exits region before timer expires, cancel/reset timer
                        if self.localPlayerCapturingPoint == true  {
                            
                            inGameInfo["playerCapturingPoint"] = "n"
                            inGameInfo["playerCapturedPoint"] = "n"
                            self.localPlayerCapturingPoint = false
                            self.localPlayerCapturedPoint = false
                            self.flagImageView.hidden = true
                            self.logEvent("Left before flag captured")

                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.logicSFX3?.play()
                            inGameInfo.saveEventually()
                            
                }
                    }
                    ////if player leaves base region, send event in UI
                    if self.baseRegion.containsCoordinate(currentCoordinate) == false {
                        self.localPlayerRegion = 1  }
                    
                    
            //NOT NEEDED AT THIS TIME determine whether another player is capturing the point
//                    let playerCapturingPoint2: String = inGameInfo.objectForKey("playerCapturingPoint") as! String
//                    if self.localPlayerCapturingPoint == false && playerCapturingPoint2 != "n" {
//                        self.playerCapturingPoint = inGameInfo.objectForKey("playerCapturingPoint") as! String
//                    }
            
            //determine whether another player has capturED the point, if so alert.
                    let playerCapturedPoint2: String = inGameInfo.objectForKey("playerCapturedPoint") as! String
                    if playerCapturedPoint2 != "n" && playerCapturedPoint != playerCapturedPoint2 && self.localPlayerCapturedPoint == false  && self.localPlayerCapturingPoint == false  && playerCapturedPoint != globalUserName  && playerCapturedPoint2 != globalUserName {
                        
                        playerCapturedPoint = playerCapturedPoint2
                        self.logEvent("\(playerCapturedPoint2) captured the flag!")
                        
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.logicCapture?.play()
                    }
                    //reset playerCapturedPoint
                        if playerCapturedPoint2 == "n" {
                            playerCapturedPoint = "n"
                        }
                    //hide flag from map if it is captured, or return it
                    if playerCapturedPoint2 != "n" && self.flagAnnotationHidden == false {
                        self.mapView.removeAnnotation(self.pointDropPin)
                        self.flagAnnotationHidden = true
                    }
                    if playerCapturedPoint2 == "n" && self.flagAnnotationHidden == true {
                        self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
                        self.mapView.addAnnotation(self.pointDropPin)
                        self.flagAnnotationHidden = false
                    }
                
                //notify if player who had the point was tagged
//                    let playerWithPointTagged2: String = inGameInfo.objectForKey("randomPlayerWithPointTagged") as! String
//                    if playerWithPointTagged2 != "n"  && playerWithPointTagged2 != self.playerWithPointTagged {
//                        
//                        self.playerWithPointTagged = playerWithPointTagged2
//                        self.logEvent("Flag returned")
//                        
//                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                        self.logicSFX4?.play()
//                    }
//                    
//                    //reset playerWithPointTagged
//                    if playerWithPointTagged2 == "n" {
//                        self.playerWithPointTagged = "n"
//                    }
                    
                    
            //determine whether offense won game
                self.gameWinner = inGameInfo.objectForKey("gameWinner") as! String
                if self.gameWinner != "n" {
                    self.captureTimer.invalidate()
                    self.itemTimer.invalidate()
                    self.gameTimer.invalidate()
                    self.offenseSystemTimer.invalidate()
                    self.errorCorrectionSystemTimer.invalidate()
                    self.timerSyncSystemTimer.invalidate()
                    self.locationManager.allowsBackgroundLocationUpdates = false
                    self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
                    self.locationManager.stopUpdatingLocation()
                self.performSegueWithIdentifier("showGameResultsViewController", sender: nil)
                    sleep(1)
            }
                    
            //if player is capturING the flag, post hearbeat
                if self.localPlayerCapturingPoint == true {
                    self.postPlayerCapturingPointHeartbeat = String(arc4random_uniform(999999))
                    inGameInfo["playerCapturingPointHeartbeat"] = self.postPlayerCapturingPointHeartbeat
                }
                
            //if player has the flag, post hearbeat
                if self.localPlayerCapturedPoint == true {
                    self.postPlayerCapturedPointHeartbeat = String(arc4random_uniform(999999))
                    inGameInfo["playerCapturedPointHeartbeat"] = self.postPlayerCapturedPointHeartbeat
                }
                    
            
            //if player is in opponent's base, change background color 
                    if self.pointRegion.containsCoordinate(currentCoordinate) == true {
                        self.view.backgroundColor = UIColor(red:1.0,green:0.503,blue:0.281,alpha:1.0)
                        print("in base background changed")
                    }
                    else {
                        self.view.backgroundColor = UIColor(red:0.6,green:0.906,blue:0.890,alpha:1.0)
                        print("in base background normal")
                    }
                
                
            //just in case of error/anomaly, reset parse flag variables if local variables indicate player does not have the flag
                let playerCapturingPointSafetyCheck: String = inGameInfo.objectForKey("playerCapturingPoint") as! String
                if (self.localPlayerCapturingPoint == false || localPlayerStatus == 0)  && playerCapturingPointSafetyCheck == globalUserName {
                    self.playerCapturingPointSafetyCheckCount++
                    if self.playerCapturingPointSafetyCheckCount == 3 {
                        self.localPlayerCapturingPoint == false
                        self.playerCapturingPointSafetyCheckCount = 0
                    inGameInfo["playerCapturingPoint"] = "n"
                    }
                    print("player capturing point safety check fired, count: \(self.playerCapturingPointSafetyCheckCount)")
                }
                else {
                    self.playerCapturingPointSafetyCheckCount = 0
                    }
                    
                let playerCapturedPointSafetyCheck: String = inGameInfo.objectForKey("playerCapturedPoint") as! String
                if (self.localPlayerCapturedPoint == false || localPlayerStatus == 0)  && playerCapturedPointSafetyCheck == globalUserName {
                    self.playerCapturedPointSafetyCheckCount++
                    if self.playerCapturedPointSafetyCheckCount == 3 {
                        self.localPlayerCapturedPoint == false
                    inGameInfo["playerCapturedPoint"] = "n"
                        self.playerCapturedPointSafetyCheckCount = 0
                    }
                    print("player captured point safety check fired, count: \(self.playerCapturedPointSafetyCheckCount)")
                }
                else {
                    self.playerCapturedPointSafetyCheckCount = 0
                    }
               
                    //clear all defense annotations
                    self.mapView.removeAnnotation(self.defense1DropPin)
                    self.mapView.removeAnnotation(self.defense2DropPin)
                    self.mapView.removeAnnotation(self.defense3DropPin)
                    self.mapView.removeAnnotation(self.defense4DropPin)
                    self.mapView.removeAnnotation(self.defense5DropPin)
                    self.mapView.removeAnnotation(self.defense1XDropPin)
                    self.mapView.removeAnnotation(self.defense2XDropPin)
                    self.mapView.removeAnnotation(self.defense3XDropPin)
                    self.mapView.removeAnnotation(self.defense4XDropPin)
                    self.mapView.removeAnnotation(self.defense5XDropPin)
                    
                    //refresh/clear offense annotations (scan, super scan, and spybot)
                    if self.spybot1Count > 0 {
                        self.spybot()
                        self.spybot1Count++
                        if self.spybot1Count == 24 {
                            self.mapView.removeAnnotation(self.spybot1DropPin)
                            self.mapView.removeOverlay(self.spybot1Circle)
                            self.spybot1Count = 0
                        }
                    }
                    if self.spybot2Count > 0 {
                        self.spybot()
                        self.spybot2Count++
                        if self.spybot2Count == 24 {
                            self.mapView.removeAnnotation(self.spybot2DropPin)
                            self.mapView.removeOverlay(self.spybot2Circle)
                            self.spybot2Count = 0
                        }
                    }
                    if self.spybot3Count > 0 {
                        self.spybot()
                        self.spybot3Count++
                        if self.spybot3Count == 24 {
                            self.mapView.removeAnnotation(self.spybot3DropPin)
                            self.mapView.removeOverlay(self.spybot3Circle)
                            self.spybot3Count = 0
                        }
                    }
                    if self.regScanCount > 0 {
                        self.scan(self.scanRegion, circle: self.scanCircle)
                        self.regScanCount++
                        if self.regScanCount == 6 {
                            self.regScanCount = 0
                        }
                    }
                    if self.scanCount > 0 {
                        self.superscan()
                        self.scanCount++
                        if self.scanCount == 12 {
                            self.scanCount = 0
                        }
                    }
                    
                    self.T = inGameInfo.objectForKey("T") as! NSArray
                    self.T2 = inGameInfo.objectForKey("T2") as! NSArray
                    if self.revealTagee1Count != 0 {
                        self.revealTagee1Count++
                        self.revealTageeRefire(self.revealTagee1)
                        if self.revealTagee1Count == 6 {
                        self.revealTagee1Count = 0
                        }
                    }
                    if self.revealTagee2Count != 0 {
                        self.revealTagee2Count++
                        self.revealTageeRefire(self.revealTagee2)
                        if self.revealTagee2Count == 6 {
                        self.revealTagee2Count = 0
                        }
                    }
                    if self.revealTagee3Count != 0 {
                        self.revealTagee3Count++
                        self.revealTageeRefire(self.revealTagee3)
                        if self.revealTagee3Count == 6 {
                        self.revealTagee3Count = 0
                        }
                    }
                    self.reportTag()
                    
               
            inGameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                if error != nil {
                      self.logEvent("Trying to connect to network..")
                        self.offenseSystemTimerCount = 5
                        }
                    
                else {
                    self.networkFailedCount = 0
                    self.offenseSystemTimerCount = 5
                }
                    
                }
            }
        }
    
        }

    }
    
//DEFENSE system timer (runs code every 5 seconds)
    func defenseSystemTimerUpdate() {
        
        if(defenseSystemTimerCount > 0)
        {
            defenseSystemTimerCount--
        }
        if(defenseSystemTimerCount == 0)
        {
            
    //UPDATE LOCATIONS
            if bluetoothOn == false && localPlayerStatus == 1 {
//                self.tagLocalPlayerByItem("na", item: "bluetooth")
            }
            
            if self.networkFailedCount == 6 {
                self.networkFailedCount = 0
                self.tagLocalPlayerByItem("na", item: "network")
            }
            
            if localPlayerStatus == 1 && (self.iconLabel.text != "Flag in place" || self.iconLabel.text != "Flag captured!" || self.iconLabel.text != "Intruder alert!") {
                if playerCapturedPoint == "n" {
                    
                    self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                    
                    self.iconLabel.text = "Flag in place"
                    
                }
                
                if playerCapturedPoint != "n" {
                    
                    self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                    
                    self.iconLabel.text = "Flag captured!"
                    
                }
                

            }
            else if localPlayerStatus == 0 && self.iconLabel.text != "Return to base" {
                self.alertIconImageView.image = UIImage(named:"walkIcon.png")
                self.iconLabel.text = "Return to base"
            }
            
            
            inGameInfo.fetchInBackgroundWithBlock {
                (inGameInfo: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print("parse error")
                    self.defenseSystemTimerCount = 2
                }
                else if let inGameInfo = inGameInfo {
                    
                    //upload geo data and status
                    inGameInfo["\(localPlayerPosition)Lat"] = self.currentLatitude
                    inGameInfo["\(localPlayerPosition)Long"] = self.currentLongitude
                    inGameInfo["\(localPlayerPosition)Status"] = localPlayerStatus
                    
                    //update flag capture vars
                    self.playerCapturingPoint = inGameInfo.objectForKey("playerCapturingPoint") as! String
                    
                //download and display teammates' locations and statues
                    if inGameInfo.objectForKey("defense1Lat") != nil && localPlayerPosition != "defense1" {
                        self.defense1Lat = inGameInfo.objectForKey("defense1Lat") as! Double
                        self.defense1Long = inGameInfo.objectForKey("defense1Long") as! Double
                        self.defense1Coordinates = CLLocationCoordinate2D(latitude: self.defense1Lat, longitude: self.defense1Long)
                        self.mapView.removeAnnotation(self.defense1DropPin)
                        self.mapView.removeAnnotation(self.defense1XDropPin)
                        defense1Status = inGameInfo.objectForKey("defense1Status") as! Int
                        
                        if defense1Status == 0 {
                            self.defense1XDropPin.coordinate = self.defense1Coordinates
                            self.defense1XDropPin.title = String(defense1var)
                            self.mapView.addAnnotation(self.defense1XDropPin)
                        }
                        else {
                        self.defense1DropPin.coordinate = self.defense1Coordinates
                            self.defense1DropPin.title = String(defense1var)
                        self.mapView.addAnnotation(self.defense1DropPin)
                        }
                    }
                    if inGameInfo.objectForKey("defense2Lat") != nil && localPlayerPosition != "defense2" {
                        self.defense2Lat = inGameInfo.objectForKey("defense2Lat") as! Double
                        self.defense2Long = inGameInfo.objectForKey("defense2Long") as! Double
                        self.defense2Coordinates = CLLocationCoordinate2D(latitude: self.defense2Lat, longitude: self.defense2Long)
                        self.mapView.removeAnnotation(self.defense2DropPin)
                        self.mapView.removeAnnotation(self.defense2XDropPin)
                        defense2Status = inGameInfo.objectForKey("defense2Status") as! Int
                        
                        if defense2Status == 0 {
                            self.defense2XDropPin.coordinate = self.defense2Coordinates
                            self.defense2XDropPin.title = String(defense2var)
                            self.mapView.addAnnotation(self.defense2XDropPin)
                        }
                        else {
                            self.defense2DropPin.coordinate = self.defense2Coordinates
                            self.defense2DropPin.title = String(defense2var)
                            self.mapView.addAnnotation(self.defense2DropPin)
                        }
                    }
                    if inGameInfo.objectForKey("defense3Lat") != nil && localPlayerPosition != "defense3" {
                        self.defense3Lat = inGameInfo.objectForKey("defense3Lat") as! Double
                        self.defense3Long = inGameInfo.objectForKey("defense3Long") as! Double
                        self.defense3Coordinates = CLLocationCoordinate2D(latitude: self.defense3Lat, longitude: self.defense3Long)
                        self.mapView.removeAnnotation(self.defense3DropPin)
                        self.mapView.removeAnnotation(self.defense3XDropPin)
                        defense3Status = inGameInfo.objectForKey("defense3Status") as! Int
                        
                        if defense3Status == 0 {
                            self.defense3XDropPin.coordinate = self.defense3Coordinates
                            self.defense3XDropPin.title = String(defense3var)
                            self.mapView.addAnnotation(self.defense3XDropPin)
                        }
                        else {
                            self.defense3DropPin.coordinate = self.defense3Coordinates
                            self.defense3DropPin.title = String(defense3var)
                            self.mapView.addAnnotation(self.defense3DropPin)
                        }
                    }
                    if inGameInfo.objectForKey("defense4Lat") != nil && localPlayerPosition != "defense4" {
                        self.defense4Lat = inGameInfo.objectForKey("defense4Lat") as! Double
                        self.defense4Long = inGameInfo.objectForKey("defense4Long") as! Double
                        self.defense4Coordinates = CLLocationCoordinate2D(latitude: self.defense4Lat, longitude: self.defense4Long)
                        self.mapView.removeAnnotation(self.defense4DropPin)
                        self.mapView.removeAnnotation(self.defense4XDropPin)
                        defense4Status = inGameInfo.objectForKey("defense4Status") as! Int
                        
                        if defense4Status == 0 {
                            self.defense4XDropPin.coordinate = self.defense4Coordinates
                            self.defense4XDropPin.title = String(defense4var)
                            self.mapView.addAnnotation(self.defense4XDropPin)
                        }
                        else {
                            self.defense4DropPin.coordinate = self.defense4Coordinates
                            self.defense4DropPin.title = String(defense4var)
                            self.mapView.addAnnotation(self.defense4DropPin)
                        }
                    }
                    if inGameInfo.objectForKey("defense5Lat") != nil && localPlayerPosition != "defense5" {
                        self.defense5Lat = inGameInfo.objectForKey("defense5Lat") as! Double
                        self.defense5Long = inGameInfo.objectForKey("defense5Long") as! Double
                        self.defense5Coordinates = CLLocationCoordinate2D(latitude: self.defense5Lat, longitude: self.defense5Long)
                        self.mapView.removeAnnotation(self.defense5DropPin)
                        self.mapView.removeAnnotation(self.defense5XDropPin)
                        defense5Status = inGameInfo.objectForKey("defense5Status") as! Int
                        
                        if defense5Status == 0 {
                            self.defense5XDropPin.coordinate = self.defense5Coordinates
                            self.defense5XDropPin.title = String(defense5var)
                            self.mapView.addAnnotation(self.defense5XDropPin)
                        }
                        else {
                            self.defense5DropPin.coordinate = self.defense5Coordinates
                            self.defense5DropPin.title = String(defense5var)
                            self.mapView.addAnnotation(self.defense5DropPin)
                        }
                    }
                    
                    //download opponents' locations (but don't display)
                    if inGameInfo.objectForKey("offense1Lat") != nil  {
                        self.offense1Lat = inGameInfo.objectForKey("offense1Lat") as! Double
                        self.offense1Long = inGameInfo.objectForKey("offense1Long") as! Double
                        self.offense1Coordinates = CLLocationCoordinate2D(latitude: self.offense1Lat, longitude: self.offense1Long)
                        self.offense1DropPin.coordinate = self.offense1Coordinates
                        self.offense1XDropPin.coordinate = self.offense1Coordinates
                        self.offense1flagDropPin.coordinate = self.offense1Coordinates
                        self.offense1DropPin.title = String(offense1var)
                        self.offense1XDropPin.title = String(offense1var)
                        self.offense1flagDropPin.title = String(offense1var)
                        offense1Status = inGameInfo.objectForKey("offense1Status") as! Int
                    }
                    if inGameInfo.objectForKey("offense2Lat") != nil  {
                        self.offense2Lat = inGameInfo.objectForKey("offense2Lat") as! Double
                        self.offense2Long = inGameInfo.objectForKey("offense2Long") as! Double
                        self.offense2Coordinates = CLLocationCoordinate2D(latitude: self.offense2Lat, longitude: self.offense2Long)
                        self.offense2DropPin.coordinate = self.offense2Coordinates
                        self.offense2XDropPin.coordinate = self.offense2Coordinates
                        self.offense2flagDropPin.coordinate = self.offense2Coordinates
                        self.offense2DropPin.title = String(offense2var)
                        self.offense2XDropPin.title = String(offense2var)
                        self.offense2flagDropPin.title = String(offense2var)
                        offense2Status = inGameInfo.objectForKey("offense2Status") as! Int
                    }
                    if inGameInfo.objectForKey("offense3Lat") != nil  {
                        self.offense3Lat = inGameInfo.objectForKey("offense3Lat") as! Double
                        self.offense3Long = inGameInfo.objectForKey("offense3Long") as! Double
                        self.offense3Coordinates = CLLocationCoordinate2D(latitude: self.offense3Lat, longitude: self.offense3Long)
                        self.offense3DropPin.coordinate = self.offense3Coordinates
                        self.offense3XDropPin.coordinate = self.offense3Coordinates
                        self.offense3flagDropPin.coordinate = self.offense3Coordinates
                        self.offense3DropPin.title = String(offense3var)
                        self.offense3XDropPin.title = String(offense3var)
                        self.offense3flagDropPin.title = String(offense3var)
                        offense3Status = inGameInfo.objectForKey("offense3Status") as! Int
                    }
                    if inGameInfo.objectForKey("offense4Lat") != nil  {
                        self.offense4Lat = inGameInfo.objectForKey("offense4Lat") as! Double
                        self.offense4Long = inGameInfo.objectForKey("offense4Long") as! Double
                        self.offense4Coordinates = CLLocationCoordinate2D(latitude: self.offense4Lat, longitude: self.offense4Long)
                        self.offense4DropPin.coordinate = self.offense4Coordinates
                        self.offense4XDropPin.coordinate = self.offense4Coordinates
                        self.offense4flagDropPin.coordinate = self.offense4Coordinates
                        self.offense4DropPin.title = String(offense4var)
                        self.offense4XDropPin.title = String(offense4var)
                        self.offense4flagDropPin.title = String(offense4var)
                        offense4Status = inGameInfo.objectForKey("offense4Status") as! Int
                    }
                    if inGameInfo.objectForKey("offense5Lat") != nil  {
                        self.offense5Lat = inGameInfo.objectForKey("offense5Lat") as! Double
                        self.offense5Long = inGameInfo.objectForKey("offense5Long") as! Double
                        self.offense5Coordinates = CLLocationCoordinate2D(latitude: self.offense5Lat, longitude: self.offense5Long)
                        self.offense5DropPin.coordinate = self.offense5Coordinates
                        self.offense5XDropPin.coordinate = self.offense5Coordinates
                        self.offense5flagDropPin.coordinate = self.offense5Coordinates
                        self.offense5DropPin.title = String(offense5var)
                        self.offense5XDropPin.title = String(offense5var)
                        self.offense5flagDropPin.title = String(offense5var)
                        offense5Status = inGameInfo.objectForKey("offense5Status") as! Int
                    }
                    
                    
                    //clear "intruder alert" iconlabel if it's been that way for 4 clock cycles
                    
                    if self.iconLabel == "Intruder alert!" {
                        self.intruderAlertResetCount++
                        if self.intruderAlertResetCount == 6 {
                            self.intruderAlertResetCount = 0
                            
                            //set the alert icon and label
                            if playerCapturedPoint == "n" {
                                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                                self.iconLabel.text = "Flag in place"
                            }
                            if playerCapturedPoint != "n" {
                                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                                self.iconLabel.text = "Flag captured!"
                            }
                            
                        }
                    }
                    else {
                        self.intruderAlertResetCount = 0
                    }

                    //determine if the player has tagged anybody, if so, play sound and reset record
//                    self.playerTaggedBy = inGameInfo.objectForKey("playerTaggedBy") as! String
//                    let playerTaggedTemp = inGameInfo.objectForKey("playerTagged") as! String
//                    if self.playerTaggedBy == localPlayerPosition {
//                            
//                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                            self.logicGotTag?.play()
//
//                        
//                        inGameInfo["playerTaggedBy"] = "n"
//                        inGameInfo["playerTagged"] = "n"
//                        self.playerTaggedBy = "n"
//                        self.logEvent("Tagged \(String(playerTaggedTemp))!")
//                        playerTagCount++
//                        
////                        self.taggedPlayerHadPointCheck = playerTaggedTemp
//                    }
   
                
            //DEFENSE PLAYER ENTERS OFFENSE BASE REGION, FLIP BIT AND PERFORM EVENTS
                    let currentCoordinate = CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude)
                    if self.baseRegion.containsCoordinate(currentCoordinate) == true {
                        self.localPlayerRegion = 1
                        
                                //defense player enters offense base, tag them
                                    if localPlayerStatus == 1 {
                                        localPlayerStatus = 0
                                        self.captureTimer.invalidate()
                                        self.logEvent("Entered opponents' base")
                                        self.alertIconImageView.image = UIImage(named:"walkIcon.png")
                                        self.iconLabel.text = "Return to base"
                                        
                                        //stop emmitting beacon
                                        self.peripheralManager.stopAdvertising()
                                        
                                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                            self.logicLoseLife?.play()
                                        
                                        //start tag timer
                                        self.tagTimerCount = 1
                                        self.tagTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("tagTimerUpdate"), userInfo: nil, repeats: true)
                                        self.tagTimer.tolerance = 0.3
                                        }
                        }
                    
                    
              //DEFENSE PLAYER ENTERS POINT REGION, FLIP BIT AND PERFORM EVENTS
                         if self.pointRegion.containsCoordinate(currentCoordinate) == true {
                            self.localPlayerRegion = 2
                        
                            //defense player enters their base at beginning of game to "power up", or tagged defense player enters base to power up
                            if localPlayerStatus == 2 {
                                localPlayerStatus = 1
                                
                                //set the alert icon and label
                                if playerCapturedPoint == "n" {
                                self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                                self.iconLabel.text = "Flag in place"
                                }
                                if playerCapturedPoint != "n" {
                                self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                                self.iconLabel.text = "Flag captured!"
                                }
                                
                                //enable beacon emitter
                                self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
                                
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.logicPowerUp?.play()

                            }
                            if localPlayerStatus == 0 {
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                self.entersound?.play()
                                self.defenseRechargeTimerCount = 10
                                self.defenseRechargeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("defenseRechargeTimerUpdate"), userInfo: nil, repeats: true)
                                self.defenseRechargeTimer.tolerance = 0.3
                                
                            }
                            
                        }
                    
                    
                    //alert if a player begins capturING
                    let randomPlayerCapturingPointTemp: String = inGameInfo.objectForKey("randomPlayerCapturingPoint") as! String
                    if randomPlayerCapturingPointTemp != "n" && randomPlayerCapturingPointTemp != self.randomPlayerCapturingPoint {
                        self.randomPlayerCapturingPoint = randomPlayerCapturingPointTemp
                        
                        if localPlayerStatus == 1 {
                        self.iconLabel.text = "Intruder alert!"
                            self.alertIconImageView.image = UIImage(named:"yellowExclaimation.png") }
                        
                        self.logEvent("Somebody in the flag zone!")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.logicSFX4?.play()
                    }
                    
                    //determine whether another player has capturED the point, if so alert, and show location
                    let playerCapturedPoint2: String = inGameInfo.objectForKey("playerCapturedPoint") as! String
                    playerCapturedPointPosition = inGameInfo.objectForKey("playerCapturedPointPosition") as! String
                    if playerCapturedPoint2 != "n" && playerCapturedPoint2 != playerCapturedPoint {
                        
                        playerCapturedPoint = playerCapturedPoint2
                        
                        self.logEvent("\(playerCapturedPoint) captured the flag!")
                        if localPlayerStatus == 1 {
                        self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                        self.iconLabel.text = "Flag captured!"
                        }
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.logicCapture?.play()
                        
                        //show location of capturer
                        self.showCapturer()
                        self.captureClearMapCycleCount = 1
                    }
                    //reset playerCapturedPoint
                    if playerCapturedPoint2 == "n" {
                        playerCapturedPoint = "n"
                    }
                    
                    //hide flag from map if it is captured, or return it
                    if playerCapturedPoint2 != "n" && self.flagAnnotationHidden == false {
                        self.mapView.removeAnnotation(self.pointDropPin)
                        self.flagAnnotationHidden = true
                    }
                    if playerCapturedPoint2 == "n" && self.flagAnnotationHidden == true {
                        self.pointDropPin = CustomPin(coordinate: self.pointCoordinates, title: "Flag", subtitle: "Not captured")
                        self.mapView.addAnnotation(self.pointDropPin)
                        self.flagAnnotationHidden = false
                    }
                    
                    //update icon label and warning (for flag status) - e.g. in case where player drops and flag resets
                    if playerCapturedPoint == "n"  && localPlayerStatus == 1 {
                        self.alertIconImageView.image = UIImage(named:"greenIcon.png")
                        self.iconLabel.text = "Flag in place"
                    }
                    if playerCapturedPoint != "n" && localPlayerStatus == 1 {
                        self.alertIconImageView.image = UIImage(named:"warningIcon.png")
                        self.iconLabel.text = "Flag captured!"
                    }
                    

                //alert if capturer is tagged
//                    let playerWithPointTagged2: String = inGameInfo.objectForKey("randomPlayerWithPointTagged") as! String
//                    let playerWithPointTaggedNameTemp: String = inGameInfo.objectForKey("playerWithPointTaggedName") as! String
//                    if playerWithPointTagged2 != "n"  && playerWithPointTagged2 != self.playerWithPointTagged {
//                        
//                        self.playerWithPointTagged = playerWithPointTagged2
//                        if playerWithPointTaggedNameTemp == self.taggedPlayerHadPointCheck {
//                            self.logEvent("Tagged \(String(playerWithPointTaggedNameTemp))! Flag returned")
//                        }
//                        else {
//                        self.logEvent("Flag returned")
//                        }
//                        if localPlayerStatus == 1 {
//                        self.alertIconImageView.image = UIImage(named:"greenIcon.png")
//                            self.iconLabel.text = "Flag in place" }
//                        
//                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                        self.logicReign?.play()
//
//                    }
//                    
//                    //reset playerWithPointTagged
//                    if playerWithPointTagged2 == "n" {
//                        self.playerWithPointTagged = "n"
//                    }
//                    
//                    //reset tagged player had point check
//                      self.taggedPlayerHadPointCheck = "n"
                    
                    
                    //determine whether offense won game
                    self.gameWinner = inGameInfo.objectForKey("gameWinner") as! String
                    if self.gameWinner != "n" {
                        self.itemTimer.invalidate()
                        self.gameTimer.invalidate()
                        self.defenseSystemTimer.invalidate()
                        self.defenseRechargeTimer.invalidate()
                        self.errorCorrectionSystemTimer.invalidate()
                        self.timerSyncSystemTimer.invalidate()
                        self.locationManager.allowsBackgroundLocationUpdates = false
                        self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
                        self.locationManager.stopUpdatingLocation()
                        self.performSegueWithIdentifier("showGameResultsViewController", sender: nil)
                    }
                    
                    //clear all offense annotations
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    
                    //refresh/clear offense annotations (scan, super scan, and spybot)
                    if self.spybot1Count > 0 {
                        self.spybot()
                        self.spybot1Count++
                        if self.spybot1Count == 24 {
                            self.mapView.removeAnnotation(self.spybot1DropPin)
                            self.mapView.removeOverlay(self.spybot1Circle)
                            self.spybot1Count = 0
                        }
                    }
                    if self.spybot2Count > 0 {
                        self.spybot()
                        self.spybot2Count++
                        if self.spybot2Count == 24 {
                            self.mapView.removeAnnotation(self.spybot2DropPin)
                            self.mapView.removeOverlay(self.spybot2Circle)
                            self.spybot2Count = 0
                        }
                    }
                    if self.spybot3Count > 0 {
                        self.spybot()
                        self.spybot3Count++
                        if self.spybot3Count == 24 {
                            self.mapView.removeAnnotation(self.spybot3DropPin)
                            self.mapView.removeOverlay(self.spybot3Circle)
                            self.spybot3Count = 0
                        }
                    }
                    if self.regScanCount > 0 {
                        self.scan(self.scanRegion, circle: self.scanCircle)
                        self.regScanCount++
                        if self.regScanCount == 6 {
                            self.regScanCount = 0
                        }
                    }
                    if self.senseCount > 0 {
                        self.scan(CLCircularRegion(center: CLLocationCoordinate2D(latitude: self.currentLatitude, longitude: self.currentLongitude), radius: CLLocationDistance(20), identifier: "sense region"), circle: MKCircle())
                        self.senseCount++
                        print("sense fired - count \(self.senseCount)")
                        if self.senseCount == 18 {
                            self.removeActiveItemImageView(14)
                            self.senseCount = 0
                        }
                    }
                    if self.scanCount > 0 {
                        self.superscan()
                        self.scanCount++
                        if self.scanCount == 12 {
                            self.scanCount = 0
                        }
                    }
                    //add (capturer)annotation
                    if self.captureClearMapCycleCount > 0 {
                        self.captureClearMapCycleCount++
                        self.showCapturer()
                        if self.captureClearMapCycleCount == 6 {
                            self.captureClearMapCycleCount = 0
                        }
                    }
                    
                    self.T = inGameInfo.objectForKey("T") as! NSArray
                    self.T2 = inGameInfo.objectForKey("T2") as! NSArray
                    if self.revealTagee1Count != 0 {
                    self.revealTageeRefire(self.revealTagee1)
                    self.revealTagee1Count++
                        if self.revealTagee1Count == 6 {
                            self.revealTagee1Count = 0
                        }
                    }
                    if self.revealTagee2Count != 0 {
                        self.revealTageeRefire(self.revealTagee2)
                        self.revealTagee2Count++
                        if self.revealTagee2Count == 6 {
                        self.revealTagee2Count = 0
                        }
                    }
                    if self.revealTagee3Count != 0 {
                        self.revealTageeRefire(self.revealTagee3)
                        self.revealTagee3Count++
                        if self.revealTagee3Count == 6 {
                        self.revealTagee3Count = 0
                        }
                    }
                    if self.lightningScanCount > 0 {
                        self.lightningScan()
                        self.lightningScanCount++
                        if self.lightningScanCount == 6 {
                            self.lightningScanCount = 0
                        }
                    }
                    self.reportTag()
                    
                    
                    inGameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if error != nil {
                            self.logEvent("Trying to connect to network..")
                           self.defenseSystemTimerCount = 5
                        }
                            
                        else {
                            self.networkFailedCount = 0
                            self.defenseSystemTimerCount = 5
                        }
                    }
                    
                }
            }
        
        }
    }
    

    
    func applicationDidEnterBackground(application: UIApplication) {
            print("app backgrounded")
            localPlayerStatus = 0
            self.captureTimer.invalidate()
            self.logEvent("Need to recharge")
            self.lifeMeterImageView.image = UIImage(named:"0life.png")
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicLoseLife?.play()
            
            //if tagged player was carrying flag or capturing it, reset PARSE and local variables
            if self.localPlayerCapturedPoint  == true || self.localPlayerCapturingPoint == true {
                
                if self.localPlayerCapturedPoint == true {
                    self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
                }
                
                
                self.localPlayerCapturingPoint = false
                self.localPlayerCapturedPoint = false
                self.flagImageView.hidden = true
                self.playerCapturingPoint = "n"
                playerCapturedPoint = "n"
                
                inGameInfo.fetchInBackgroundWithBlock {
                    (inGameInfo: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print("parse error")  }
                    else if let inGameInfo = inGameInfo {
                        inGameInfo["playerCapturingPoint"] = "n"
                        inGameInfo["playerCapturedPoint"] = "n"
                        
                        //indicate who tagged the player
                        inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
                        inGameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if error != nil {
                                print(error)
                                inGameInfo.saveEventually()
                            }
                            
                        }
    
                    }
                    
                }
                //tagged player loses flag/stops capturing
                self.localPlayerCapturingPoint = false
                self.localPlayerCapturedPoint = false
                self.flagImageView.hidden = true
                self.captureTimer.invalidate()
            }
        }
    
    func quitGame() {
        self.backsound?.play()
        let refreshAlert = UIAlertController(title: "Exit game", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.captureTimer.invalidate()
            self.itemTimer.invalidate()
            self.gameTimer.invalidate()
            self.offenseSystemTimer.invalidate()
            self.defenseSystemTimer.invalidate()
            self.defenseRechargeTimer.invalidate()
            self.errorCorrectionSystemTimer.invalidate()
            self.timerSyncSystemTimer.invalidate()
            self.tagTimer.invalidate()
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.stopRangingBeaconsInRegion(self.detectionRegion)
            self.locationManager.stopUpdatingLocation()
            self.performSegueWithIdentifier("showFirstViewControllerFromGameViewController", sender: nil)
            
            slot1Powerup = 0
            slot2Powerup = 0
            slot3Powerup = 0
            currentFunds = 0
            map3d = true
            quittingGame = false
            globalDefenseWonGame = false
            playerTagCount = 0
            globalIsOffense = false
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func itemShopButtonIcon(sender: AnyObject) {
        if globalIsOffense == true {
            self.performSegueWithIdentifier("showOffenseItemShopViewControllerFromGameViewController", sender: nil)
        }
        else {
            self.performSegueWithIdentifier("showDefenseItemShopViewControllerFromGameViewController", sender: nil)
        }
    }
    
    @IBAction func gameMenuButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showGameMenuViewControllerFromGameViewController", sender: nil)
        self.entersoundlow?.play()
    }

    @IBAction func newsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showEventLogViewControllerFromGameViewController", sender: nil)
        self.entersoundlow?.play()
    }
    

    func tagLocalOffensePlayerByMine(taggedBy: String) {
        localPlayerStatus = 0
        self.captureTimer.invalidate()
        
        self.lifeMeterImageView.image = UIImage(named:"0life.png")
        self.logicCapturing2?.stop()
        self.logicCapturing2?.currentTime = 0
        self.captureTimer.invalidate()
//        let localPlayerCapturingPointTemp = self.localPlayerCapturingPoint
//        let localPlayerCapturedPointTemp = self.localPlayerCapturedPoint
        self.localPlayerCapturingPoint = false
        self.localPlayerCapturedPoint = false
        self.flagImageView.hidden = true
        
        self.logEvent("Tagged by \(taggedBy)'s mine")
        self.bombtag?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        //start tag timer
        self.tagTimerCount = 1
        self.tagTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("tagTimerUpdate"), userInfo: nil, repeats: true)
        self.tagTimer.tolerance = 0.3
        
//        if localPlayerCapturingPointTemp == true || localPlayerCapturedPointTemp == true {
//        inGameInfo.fetchInBackgroundWithBlock {
//            (inGameInfo: PFObject?, error: NSError?) -> Void in
//            if error != nil {
//                print("parse error")  }
//            else if let inGameInfo = inGameInfo {
//                    
//                    if localPlayerCapturedPointTemp == true {
//                        self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
//                        inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
//                        inGameInfo["playerWithPointTaggedName"] = globalUserName
//                    }
//                    
//                    inGameInfo["playerCapturingPoint"] = "n"
//                    inGameInfo["playerCapturedPoint"] = "n"
//                    inGameInfo["playerCapturingPointPosition"] = "n"
//                    inGameInfo["playerCapturedPointPosition"] = "n"
//                
//                inGameInfo.saveEventually() { (success: Bool, error: NSError?) -> Void in
//                    if error != nil {
//                        self.logEvent("Trying to connect to network..")
//                    }
//                    
//                }
//                
//            }
//        }
//        }
        
    }
    
    func tagLocalDefensePlayerByMine(taggedBy: String) {
        localPlayerStatus = 0
        self.captureTimer.invalidate()
        self.alertIconImageView.image = UIImage(named:"walkIcon.png")
        self.iconLabel.text = "Return to base"
        self.logEvent("Tagged by \(taggedBy)'s mine")
        
        //stop emmitting beacon
        self.peripheralManager.stopAdvertising()
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
       self.bombtag?.play()
        
        //start tag timer
        self.tagTimerCount = 1
        self.tagTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("tagTimerUpdate"), userInfo: nil, repeats: true)
        self.tagTimer.tolerance = 0.3
        
    }
    
    func tagLocalPlayerByItem(taggedBy: String, item: String) {
        localPlayerStatus = 0
        self.captureTimer.invalidate()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if item == "bluetooth" {
            self.logicLoseLife?.play()
            displayAlert("Bluetooth disabled", message: "You automatically get tagged when you disable bluetooth! Enable bluetooth to continue playing. Make sure airplane mode is disabled.")
        }
        else if item == "network" {
            self.logicLoseLife?.play()
            displayAlert("Network failure", message: "To prevent cheating, you are automatically tagged when your internet connection fails for an extended period.  Make sure airpline mode is disabled.")
        }
        else {
        self.logEvent("Tagged by \(taggedBy)'s \(item)!")
        
        if item == "bomb" {
        self.bombtag?.play()
        }
        if item == "sickle" {
            self.sickletag?.play()
        }
        if item == "lightning" {
            self.lightningtag?.play()
        }
        }
        
        //start tag timer
        self.tagTimerCount = 1
        self.tagTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("tagTimerUpdate"), userInfo: nil, repeats: true)
        self.tagTimer.tolerance = 0.3
        
        if globalIsOffense == false {
            self.alertIconImageView.image = UIImage(named:"walkIcon.png")
            self.iconLabel.text = "Return to base"
            
            //stop emmitting beacon
            self.peripheralManager.stopAdvertising()
        }
        
        if globalIsOffense == true {
        self.lifeMeterImageView.image = UIImage(named:"0life.png")
        self.logicCapturing2?.stop()
        self.logicCapturing2?.currentTime = 0
        self.captureTimer.invalidate()
        let localPlayerCapturingPointTemp = self.localPlayerCapturingPoint
        let localPlayerCapturedPointTemp = self.localPlayerCapturedPoint
        self.localPlayerCapturingPoint = false
        self.localPlayerCapturedPoint = false
        self.flagImageView.hidden = true
        
            
        //for other types of item tags, the post to indicate flag return/capturing stop is handled by func postTag, but lightning/bluetooth/netowrk tags are not
            if item == "lightning" || item == "bluetooth" || item == "network" {
        if localPlayerCapturingPointTemp == true || localPlayerCapturedPointTemp == true {
        inGameInfo.fetchInBackgroundWithBlock {
            (inGameInfo: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print("parse error")  }
            else if let inGameInfo = inGameInfo {
                    
                    if localPlayerCapturedPointTemp == true {
                        self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
                        inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
                        inGameInfo["playerWithPointTaggedName"] = globalUserName
                    }
                    
                    inGameInfo["playerCapturingPoint"] = "n"
                    inGameInfo["playerCapturedPoint"] = "n"
                    inGameInfo["playerCapturingPointPosition"] = "n"
                    inGameInfo["playerCapturedPointPosition"] = "n"

                inGameInfo.saveEventually { (success: Bool, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                        self.logEvent("Trying to connect to network..")
                    }
                    
                }
                
            }
        }
        }
    }
            
            
            
        }
    }
    
//    func tagLocalPlayerBySickle(taggedBy: String) {
//        if localPlayerStatus == 1 {
//        localPlayerStatus = 0
//        
//        self.lifeMeterImageView.image = UIImage(named:"0life.png")
//        self.logicCapturing2?.stop()
//        self.captureTimer.invalidate()
//        let localPlayerCapturingPointTemp = self.localPlayerCapturingPoint
//        let localPlayerCapturedPointTemp = self.localPlayerCapturedPoint
//        self.localPlayerCapturingPoint = false
//        self.localPlayerCapturedPoint = false
//        self.flagImageView.hidden = true
//        
//        self.logEvent("Tagged by \(taggedBy)'s sickle")
//        self.sickletag?.play()
//        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//        
//        if globalIsOffense == true && (localPlayerCapturingPointTemp == true || localPlayerCapturedPointTemp == true) {
//            inGameInfo.fetchInBackgroundWithBlock {
//                (inGameInfo: PFObject?, error: NSError?) -> Void in
//                if error != nil {
//                    print("parse error")  }
//                else if let inGameInfo = inGameInfo {
//                    
//                    //if tagged player was carrying flag or capturing it, reset PARSE and local variables
//                    if localPlayerCapturedPointTemp  == true || localPlayerCapturingPointTemp == true {
//                        
//                        if localPlayerCapturedPointTemp == true {
//                            self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
//                            inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
//                            inGameInfo["playerWithPointTaggedName"] = globalUserName
//                        }
//                        
//                        inGameInfo["playerCapturingPoint"] = "n"
//                        inGameInfo["playerCapturedPoint"] = "n"
    //                        inGameInfo["playerCapturingPoint"] = "n"
    //                        inGameInfo["playerCapturedPoint"] = "n"
//                        
//                    }
//                    
//                    inGameInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                        if error != nil {
//                            print(error)
//                            self.logEvent("Trying to connect to network..")
//                            inGameInfo.saveEventually()
//                        }
//                        
//                    }
//                    
//                }
//            }
//        }
//        }
//    }
    
    
    
    func scan(region: CLCircularRegion, circle: MKCircle) {
        
        if self.jammerCount == 0 {
        //if player is offense, show all defense players in scan region
        if globalIsOffense == true {
            
            if region.containsCoordinate(defense1Coordinates) {
                self.mapView.removeAnnotation(self.defense1DropPin)
                self.mapView.removeAnnotation(self.defense1XDropPin)
                if defense1Status == 0 {
                    self.mapView.addAnnotation(self.defense1XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense1DropPin)
                }
            }
            if region.containsCoordinate(defense2Coordinates) {
                self.mapView.removeAnnotation(self.defense2DropPin)
                self.mapView.removeAnnotation(self.defense2XDropPin)
                if defense2Status == 0 {
                    self.mapView.addAnnotation(self.defense2XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense2DropPin)
                }
            }
            if region.containsCoordinate(defense3Coordinates) {
                self.mapView.removeAnnotation(self.defense3DropPin)
                self.mapView.removeAnnotation(self.defense3XDropPin)
                if defense3Status == 0 {
                    self.mapView.addAnnotation(self.defense3XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense3DropPin)
                }
            }
            if region.containsCoordinate(defense4Coordinates) {
                self.mapView.removeAnnotation(self.defense4DropPin)
                self.mapView.removeAnnotation(self.defense4XDropPin)
                if defense4Status == 0 {
                    self.mapView.addAnnotation(self.defense4XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense4DropPin)
                }
            }
            if region.containsCoordinate(defense5Coordinates) {
                self.mapView.removeAnnotation(self.defense5DropPin)
                self.mapView.removeAnnotation(self.defense5XDropPin)
                if defense5Status == 0 {
                    self.mapView.addAnnotation(self.defense5XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense5DropPin)
                }
            }
            
        }
        
        //if player is defense, show all offense players in scan region
        if globalIsOffense != true {
            
            if region.containsCoordinate(offense1Coordinates) {
                self.mapView.removeAnnotation(self.offense1DropPin)
                self.mapView.removeAnnotation(self.offense1XDropPin)
                self.mapView.removeAnnotation(self.offense1flagDropPin)
                
                if playerCapturedPointPosition == "offense1" {
                    self.mapView.addAnnotation(self.offense1flagDropPin)
                }
                else if offense1Status == 0 {
                    self.mapView.addAnnotation(self.offense1XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense1DropPin)
                }
            }
            if region.containsCoordinate(offense2Coordinates) {
                self.mapView.removeAnnotation(self.offense2DropPin)
                self.mapView.removeAnnotation(self.offense2XDropPin)
                self.mapView.removeAnnotation(self.offense2flagDropPin)
                
                if playerCapturedPointPosition == "offense2" {
                    self.mapView.addAnnotation(self.offense2flagDropPin)
                }
                else if offense2Status == 0 {
                    self.mapView.addAnnotation(self.offense2XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense2DropPin)
                }
            }
            if region.containsCoordinate(offense3Coordinates) {
                self.mapView.removeAnnotation(self.offense3DropPin)
                self.mapView.removeAnnotation(self.offense3XDropPin)
                self.mapView.removeAnnotation(self.offense3flagDropPin)
                
                if playerCapturedPointPosition == "offense3" {
                    self.mapView.addAnnotation(self.offense3flagDropPin)
                }
                else if offense3Status == 0 {
                    self.mapView.addAnnotation(self.offense3XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense3DropPin)
                }
            }
            if region.containsCoordinate(offense4Coordinates) {
                self.mapView.removeAnnotation(self.offense4DropPin)
                self.mapView.removeAnnotation(self.offense4XDropPin)
                self.mapView.removeAnnotation(self.offense4flagDropPin)
                
                if playerCapturedPointPosition == "offense4" {
                    self.mapView.addAnnotation(self.offense4flagDropPin)
                }
                else if offense4Status == 0 {
                    self.mapView.addAnnotation(self.offense4XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense4DropPin)
                }
            }
            if region.containsCoordinate(offense5Coordinates) {
                self.mapView.removeAnnotation(self.offense5DropPin)
                self.mapView.removeAnnotation(self.offense5XDropPin)
                self.mapView.removeAnnotation(self.offense5flagDropPin)
                
                if playerCapturedPointPosition == "offense5" {
                    self.mapView.addAnnotation(self.offense5flagDropPin)
                }
                else if offense5Status == 0 {
                    self.mapView.addAnnotation(self.offense5XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense5DropPin)
                }
            }
            
        }
        }
    }
    
    func lightningScan() {
        
                if self.offense1Lat != 0 {
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    

                        self.mapView.addAnnotation(self.offense1XDropPin)

                }
                if self.offense2Lat != 0 {
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    
                        self.mapView.addAnnotation(self.offense2XDropPin)

                }
                if self.offense3Lat != 0 {
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    
                        self.mapView.addAnnotation(self.offense3XDropPin)

                }
                if self.offense4Lat != 0 {
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    
                        self.mapView.addAnnotation(self.offense4XDropPin)
                    
                }
                if self.offense5Lat != 0 {
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    
                        self.mapView.addAnnotation(self.offense5XDropPin)

                }
    }
    
    func superscan() {
        if self.jammerCount == 0 {
            //if player is offense, show all defense players
            if globalIsOffense == true {
                
                if self.defense1Lat != 0 {
                    self.mapView.removeAnnotation(self.defense1DropPin)
                    self.mapView.removeAnnotation(self.defense1XDropPin)
                    if defense1Status == 0 {
                        self.mapView.addAnnotation(self.defense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense1DropPin)
                    }
                }
                if self.defense2Lat != 0 {
                    self.mapView.removeAnnotation(self.defense2DropPin)
                    self.mapView.removeAnnotation(self.defense2XDropPin)
                    if defense2Status == 0 {
                        self.mapView.addAnnotation(self.defense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense2DropPin)
                    }
                }
                if self.defense3Lat != 0 {
                    self.mapView.removeAnnotation(self.defense3DropPin)
                    self.mapView.removeAnnotation(self.defense3XDropPin)
                    if defense3Status == 0 {
                        self.mapView.addAnnotation(self.defense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense3DropPin)
                    }
                }
                if self.defense4Lat != 0 {
                    self.mapView.removeAnnotation(self.defense4DropPin)
                    self.mapView.removeAnnotation(self.defense4XDropPin)
                    if defense4Status == 0 {
                        self.mapView.addAnnotation(self.defense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense4DropPin)
                    }
                }
                if self.defense5Lat != 0 {
                    self.mapView.removeAnnotation(self.defense5DropPin)
                    self.mapView.removeAnnotation(self.defense5XDropPin)
                    if defense5Status == 0 {
                        self.mapView.addAnnotation(self.defense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.defense5DropPin)
                    }
                }
                
            }
            
            //if player is defense, show all offense players
            if globalIsOffense != true {
                
                if self.offense1Lat != 0 {
                    self.mapView.removeAnnotation(self.offense1DropPin)
                    self.mapView.removeAnnotation(self.offense1XDropPin)
                    self.mapView.removeAnnotation(self.offense1flagDropPin)
                    
                    if playerCapturedPointPosition == "offense1" {
                        self.mapView.addAnnotation(self.offense1flagDropPin)
                    }
                    else if offense1Status == 0 {
                        self.mapView.addAnnotation(self.offense1XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense1DropPin)
                    }
                }
                if self.offense2Lat != 0 {
                    self.mapView.removeAnnotation(self.offense2DropPin)
                    self.mapView.removeAnnotation(self.offense2XDropPin)
                    self.mapView.removeAnnotation(self.offense2flagDropPin)
                    
                    if playerCapturedPointPosition == "offense2" {
                        self.mapView.addAnnotation(self.offense2flagDropPin)
                    }
                    else if offense2Status == 0 {
                        self.mapView.addAnnotation(self.offense2XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense2DropPin)
                    }
                }
                if self.offense3Lat != 0 {
                    self.mapView.removeAnnotation(self.offense3DropPin)
                    self.mapView.removeAnnotation(self.offense3XDropPin)
                    self.mapView.removeAnnotation(self.offense3flagDropPin)
                    
                    if playerCapturedPointPosition == "offense3" {
                        self.mapView.addAnnotation(self.offense3flagDropPin)
                    }
                    else if offense3Status == 0 {
                        self.mapView.addAnnotation(self.offense3XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense3DropPin)
                    }
                }
                if self.offense4Lat != 0 {
                    self.mapView.removeAnnotation(self.offense4DropPin)
                    self.mapView.removeAnnotation(self.offense4XDropPin)
                    self.mapView.removeAnnotation(self.offense4flagDropPin)
                    
                    if playerCapturedPointPosition == "offense4" {
                        self.mapView.addAnnotation(self.offense4flagDropPin)
                    }
                    else if offense4Status == 0 {
                        self.mapView.addAnnotation(self.offense4XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense4DropPin)
                    }
                }
                if self.offense5Lat != 0 {
                    self.mapView.removeAnnotation(self.offense5DropPin)
                    self.mapView.removeAnnotation(self.offense5XDropPin)
                    self.mapView.removeAnnotation(self.offense5flagDropPin)
                    
                    if playerCapturedPointPosition == "offense5" {
                        self.mapView.addAnnotation(self.offense5flagDropPin)
                    }
                    else if offense5Status == 0 {
                        self.mapView.addAnnotation(self.offense5XDropPin)
                    }
                    else {
                        self.mapView.addAnnotation(self.offense5DropPin)
                    }
                }
                
            }
        }
    }
    
    func dropSpybot(lat: Double, long: Double, player: String) {
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        if self.spybot1Dropped == false || (self.firstSpybotDropped != 1 && self.secondSpybotDropped != 1) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot1Count = 1
            self.mapView.removeAnnotation(self.spybot1DropPin)
            self.mapView.removeOverlay(self.spybot1Circle)
            self.spybot1Dropped = true
            self.spybot1DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot1DropPin)
            self.spybot1Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot1Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(15))
            self.mapView.addOverlay(self.spybot1Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 1
            //self.scan(self.spybot1Region, circle: self.spybot1Circle)
            self.logEvent("Spybot planted!")
            self.spybot()
        }
        
        else if self.spybot2Dropped == false || (self.firstSpybotDropped != 2 && self.secondSpybotDropped != 2) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot2Count = 1
            self.mapView.removeAnnotation(self.spybot2DropPin)
            self.mapView.removeOverlay(self.spybot2Circle)
            self.spybot2Dropped = true
            self.spybot2DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot2DropPin)
            self.spybot2Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot2Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(15))
            self.mapView.addOverlay(self.spybot2Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 2
            //self.scan(self.spybot2Region, circle: self.spybot2Circle)
            self.logEvent("Spybot planted!")
            self.spybot()
        }
        
        else if self.spybot3Dropped == false || (self.firstSpybotDropped != 3 && self.secondSpybotDropped != 3) {
            self.spybotsound?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.spybot3Count = 1
            self.mapView.removeAnnotation(self.spybot3DropPin)
            self.mapView.removeOverlay(self.spybot3Circle)
            self.spybot3Dropped = true
            self.spybot3DropPin = CustomPinSpybot(coordinate: coord, title: "\(player)'s spybot")
            self.mapView.addAnnotation(self.spybot3DropPin)
            self.spybot3Region = CLCircularRegion(center: coord, radius: CLLocationDistance(15), identifier: "")
            self.spybot3Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(15))
            self.mapView.addOverlay(self.spybot3Circle)
            self.secondSpybotDropped = self.firstSpybotDropped
            self.firstSpybotDropped = 3
            //self.scan(self.spybot3Region, circle: self.spybot3Circle)
            self.logEvent("Spybot planted!")
            self.spybot()
        }
        
    }
    
    func spybot() {
        if self.jammerCount == 0 {
        if globalIsOffense == true {
            
            if self.spybot1Region.containsCoordinate(self.defense1Coordinates) || self.spybot2Region.containsCoordinate(self.defense1Coordinates) || self.spybot3Region.containsCoordinate(self.defense1Coordinates) {
                self.mapView.removeAnnotation(self.defense1DropPin)
                self.mapView.removeAnnotation(self.defense1XDropPin)
                if defense1Status == 0 {
                self.mapView.addAnnotation(self.defense1XDropPin)
                }
                else {
                self.mapView.addAnnotation(self.defense1DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.defense2Coordinates) || self.spybot2Region.containsCoordinate(self.defense2Coordinates) || self.spybot3Region.containsCoordinate(self.defense2Coordinates)  {
                self.mapView.removeAnnotation(self.defense2DropPin)
                self.mapView.removeAnnotation(self.defense2XDropPin)
                if defense2Status == 0 {
                    self.mapView.addAnnotation(self.defense2XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense2DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.defense3Coordinates) || self.spybot2Region.containsCoordinate(self.defense3Coordinates) || self.spybot3Region.containsCoordinate(self.defense3Coordinates) {
                self.mapView.removeAnnotation(self.defense3DropPin)
                self.mapView.removeAnnotation(self.defense3XDropPin)
                if defense3Status == 0 {
                    self.mapView.addAnnotation(self.defense3XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense3DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.defense4Coordinates) || self.spybot2Region.containsCoordinate(self.defense4Coordinates) || self.spybot3Region.containsCoordinate(self.defense4Coordinates) {
                self.mapView.removeAnnotation(self.defense4DropPin)
                self.mapView.removeAnnotation(self.defense4XDropPin)
                if defense4Status == 0 {
                    self.mapView.addAnnotation(self.defense4XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense4DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.defense5Coordinates) || self.spybot2Region.containsCoordinate(self.defense5Coordinates) || self.spybot3Region.containsCoordinate(self.defense5Coordinates) {
                self.mapView.removeAnnotation(self.defense5DropPin)
                self.mapView.removeAnnotation(self.defense5XDropPin)
                if defense5Status == 0 {
                    self.mapView.addAnnotation(self.defense5XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.defense5DropPin)
                }
            }
            

            
        }
        
        if globalIsOffense == false {
            
            if self.spybot1Region.containsCoordinate(self.offense1Coordinates) || self.spybot2Region.containsCoordinate(self.offense1Coordinates) || self.spybot3Region.containsCoordinate(self.offense1Coordinates) {
                self.mapView.removeAnnotation(self.offense1DropPin)
                self.mapView.removeAnnotation(self.offense1XDropPin)
                self.mapView.removeAnnotation(self.offense1flagDropPin)
                
                if playerCapturedPointPosition == "offense1" {
                    self.mapView.addAnnotation(self.offense1flagDropPin)
                }
                else if offense1Status == 0 {
                    self.mapView.addAnnotation(self.offense1XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense1DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.offense2Coordinates) || self.spybot2Region.containsCoordinate(self.offense2Coordinates) || self.spybot3Region.containsCoordinate(self.offense2Coordinates) {
                self.mapView.removeAnnotation(self.offense2DropPin)
                self.mapView.removeAnnotation(self.offense2XDropPin)
                self.mapView.removeAnnotation(self.offense2flagDropPin)
                
                if playerCapturedPointPosition == "offense2" {
                    self.mapView.addAnnotation(self.offense2flagDropPin)
                }
                else if offense2Status == 0 {
                    self.mapView.addAnnotation(self.offense2XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense2DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.offense3Coordinates) || self.spybot2Region.containsCoordinate(self.offense3Coordinates) || self.spybot3Region.containsCoordinate(self.offense3Coordinates) {
                self.mapView.removeAnnotation(self.offense3DropPin)
                self.mapView.removeAnnotation(self.offense3XDropPin)
                self.mapView.removeAnnotation(self.offense3flagDropPin)
                
                if playerCapturedPointPosition == "offense3" {
                    self.mapView.addAnnotation(self.offense3flagDropPin)
                }
                else if offense3Status == 0 {
                    self.mapView.addAnnotation(self.offense3XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense3DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.offense4Coordinates) || self.spybot2Region.containsCoordinate(self.offense4Coordinates) || self.spybot3Region.containsCoordinate(self.offense4Coordinates) {
                self.mapView.removeAnnotation(self.offense4DropPin)
                self.mapView.removeAnnotation(self.offense4XDropPin)
                self.mapView.removeAnnotation(self.offense4flagDropPin)
                
                if playerCapturedPointPosition == "offense4" {
                    self.mapView.addAnnotation(self.offense4flagDropPin)
                }
                else if offense4Status == 0 {
                    self.mapView.addAnnotation(self.offense4XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense4DropPin)
                }
            }
            if self.spybot1Region.containsCoordinate(self.offense5Coordinates) || self.spybot2Region.containsCoordinate(self.offense5Coordinates) || self.spybot3Region.containsCoordinate(self.offense5Coordinates) {
                self.mapView.removeAnnotation(self.offense5DropPin)
                self.mapView.removeAnnotation(self.offense5XDropPin)
                self.mapView.removeAnnotation(self.offense5flagDropPin)
                
                if playerCapturedPointPosition == "offense5" {
                    self.mapView.addAnnotation(self.offense5flagDropPin)
                }
                else if offense5Status == 0 {
                    self.mapView.addAnnotation(self.offense5XDropPin)
                }
                else {
                    self.mapView.addAnnotation(self.offense5DropPin)
                }
            }
        }
        }
    }
    
    func heal() {
        if localPlayerStatus != 2 {
            localPlayerStatus = 1
            
            self.alertIconImageView.hidden = true
            self.iconLabel.hidden = true
            self.lifeMeterImageView.hidden = false
            self.lifeMeterImageView.image = UIImage(named:"5life.png")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.logicPowerUp?.play()
        }
        
    }
    
    func showItemView() {
        self.entersoundlow?.play()
        self.itemViewHidden = false
        self.targetImageView.hidden = true
        self.itemButtonBackdropImageView.hidden = false
        self.itemLabelIconImageView.hidden = false
        self.itemLabel.hidden = false
        self.useButtonOutlet.hidden = false
        self.helpButtonOutlet.hidden = false
        self.cancelButtonOutlet.hidden = false
        mapView.pitchEnabled = true
        mapView.zoomEnabled = true
    }
    
    func showTargetItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let heading = mapView.camera.heading
        let mapCamera2 = MKMapCamera(lookingAtCenterCoordinate: center, fromDistance: 225, pitch: 0, heading: heading)
        self.mapView.setCamera(mapCamera2, animated: true)
        mapView.pitchEnabled = false
        mapView.zoomEnabled = false
        
        self.targetImageView.image = UIImage(named:"target.png")
        self.itemViewHidden = false
        self.targetImageView.hidden = false
        self.itemButtonBackdropImageView.hidden = false
        self.itemLabelIconImageView.hidden = false
        self.itemLabel.hidden = false
        self.useButtonOutlet.hidden = false
        self.helpButtonOutlet.hidden = false
        self.cancelButtonOutlet.hidden = false
    }
    
    func showRadarItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let heading = mapView.camera.heading
        let mapCamera2 = MKMapCamera(lookingAtCenterCoordinate: center, fromDistance: 225, pitch: 0, heading: heading)
        self.mapView.setCamera(mapCamera2, animated: true)
        mapView.pitchEnabled = false
        mapView.zoomEnabled = false
        
        self.targetImageView.image = UIImage(named:"radar.png")
        self.itemViewHidden = false
        self.targetImageView.hidden = false
        self.itemButtonBackdropImageView.hidden = false
        self.itemLabelIconImageView.hidden = false
        self.itemLabel.hidden = false
        self.useButtonOutlet.hidden = false
        self.helpButtonOutlet.hidden = false
        self.cancelButtonOutlet.hidden = false
    }
    
    func showSpybotItemView() {
        self.showtargetimageview?.play()
        let center = mapView.camera.centerCoordinate
        let heading = mapView.camera.heading
        let mapCamera2 = MKMapCamera(lookingAtCenterCoordinate: center, fromDistance: 225, pitch: 0, heading: heading)
        self.mapView.setCamera(mapCamera2, animated: true)
        mapView.pitchEnabled = false
        mapView.zoomEnabled = false
        
        self.targetImageView.image = UIImage(named:"spybotoverlay.png")
        self.itemViewHidden = false
        self.targetImageView.hidden = false
        self.itemButtonBackdropImageView.hidden = false
        self.itemLabelIconImageView.hidden = false
        self.itemLabel.hidden = false
        self.useButtonOutlet.hidden = false
        self.helpButtonOutlet.hidden = false
        self.cancelButtonOutlet.hidden = false
    }
    
    func clearAfterUse() {
        
        mapView.pitchEnabled = true
        mapView.zoomEnabled = true
        self.itemViewHidden = true
        self.targetImageView.hidden = true
        self.itemButtonBackdropImageView.hidden = true
        self.itemLabelIconImageView.hidden = true
        self.itemLabel.hidden = true
        self.useButtonOutlet.hidden = true
        self.helpButtonOutlet.hidden = true
        self.cancelButtonOutlet.hidden = true
        
        if self.activePowerupSlot == 1 {
            self.powerup1ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, forState: .Normal)
            //self.powerup1ButtonOutlet.enabled = false
            slot1Powerup = 0
            
        }
        if self.activePowerupSlot == 2 {
            self.powerup2ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, forState: .Normal)
            //self.powerup2ButtonOutlet.enabled = false
            slot2Powerup = 0
        }
        if self.activePowerupSlot == 3 {
            self.powerup3ButtonOutlet.setImage(UIImage(named: "emptyBox.png") as UIImage?, forState: .Normal)
            //self.powerup3ButtonOutlet.enabled = false
            slot3Powerup = 0
        }
        self.activePowerupSlot = 0
        activePowerup = 0
    }
    
    func showCapturer() {
        if playerCapturedPointPosition == "offense1" {
            self.mapView.addAnnotation(self.offense1flagDropPin)
        }
        if playerCapturedPointPosition == "offense2" {
            self.mapView.addAnnotation(self.offense2flagDropPin)
        }
        if playerCapturedPointPosition == "offense3" {
            self.mapView.addAnnotation(self.offense3flagDropPin)
        }
        if playerCapturedPointPosition == "offense4" {
            self.mapView.addAnnotation(self.offense4flagDropPin)
        }
        if playerCapturedPointPosition == "offense5" {
            self.mapView.addAnnotation(self.offense5flagDropPin)
        }
        
    }
    
    func refreshItems() {
        self.fundsLabel.text = "\(currentFunds)"
        
        if slot1Powerup == 0 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"emptyBox.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 1 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 2 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 3 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 4 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 5 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 6 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 7 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 8 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 9 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 10 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 11 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 12 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 13 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 14 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 15 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot1Powerup == 16 {
            self.powerup1ButtonOutlet.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
        if slot2Powerup == 0 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"emptyBox.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 1 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 2 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 3 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 4 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 5 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 6 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 7 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 8 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 9 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 10 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 11 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 12 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 13 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 14 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 15 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot2Powerup == 16 {
            self.powerup2ButtonOutlet.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 0 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"emptyBox.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 1 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"scan.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 2 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"superscan.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 3 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"mine40.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 4 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"supermine.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 5 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"bomb.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 6 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"superbomb.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 7 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"jammer.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 8 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"spybot.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 9 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"heal.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 10 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"superheal.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 11 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"shield.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 12 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"ghost.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 13 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"reach.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 14 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"fist.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 15 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"sickle.png"), forState: UIControlState.Normal)
        }
        if slot3Powerup == 16 {
            self.powerup3ButtonOutlet.setImage(UIImage(named:"lightning.png"), forState: UIControlState.Normal)
        }
        
    }
    
    
    func weightedDropRoll() {
        if self.all5Dropped == false {
            
        //item abundance 1 -  ~5.8min av
        if self.itemAbundance == 1 {
        dropRoll(50)
        }
        
        //item abundance 2 -  ~2.9min av
        else if self.itemAbundance == 2 {
        dropRoll(25)
        }
        
        //item abundance 3 -  ~1.9min av
        else if self.itemAbundance == 3 {
        dropRoll(16)
        }
            
        //item abundance 4 -  ~1.1 min av
        else if self.itemAbundance == 4 {
        dropRoll(10)
        }
            
        //item abundance 5 -  ~.65 min av
        else if self.itemAbundance == 5 {
        dropRoll(6)
        }
        
        }
        
        else {
            //item abundance 1
            if self.itemAbundance == 1 {
                dropRoll(60)
            }
                
                //item abundance 2
            else if self.itemAbundance == 2 {
                dropRoll(45)
            }
                
                //item abundance 3
            else if self.itemAbundance == 3 {
                dropRoll(40)
            }
                
                //item abundance 4
            else if self.itemAbundance == 4 {
                dropRoll(30)
            }
                
                //item abundance 5
            else if self.itemAbundance == 5 {
                dropRoll(30)
            }
        }
    }
    
    func dropRoll(odds: Int) {
        
        let odds2 = UInt32(odds)
        let roll = Int(arc4random_uniform(odds2) + 1)
        
        print("odds \(odds)")
        print("odds2 \(odds2)")
        print("roll \(roll)")
        print("geomodeon \(self.geoModeOn)")
        
        if roll == 2  && self.geoModeOn == true {
            let roll2 = Int(arc4random_uniform(15) + 1)
            print("roll2 \(roll2)")
            if roll2 == 5 {
                genItem()
                print("placed item directly")
                self.directitem?.play()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            else {
                print("rolled item location")
                rollItemLocation()
            }
        }
        if roll == 2  && self.geoModeOn == false {
            genItem()
            self.directitem?.play()
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
    }
    
    
    func genItem() {
        
        let roll = Int(arc4random_uniform(55) + 1)
        
        if roll >= 1 && roll <= 8 {
            if itemsDisabled[0] as! Bool == false {
                placeItem(1) }
            else { genItem() }
        }
        if roll >= 7 && roll <= 10  {
            if itemsDisabled[1] as! Bool == false {
                placeItem(2) }
            else { genItem() }
        }
        if roll >= 11 && roll <= 14  {
            if itemsDisabled[2] as! Bool == false {
                placeItem(3) }
            else { genItem() }
        }
        if roll >= 15 && roll <= 16 {
            if itemsDisabled[3] as! Bool == false {
                placeItem(4) }
            else { genItem() }
        }
        if roll >= 17 && roll <= 20 {
            if itemsDisabled[4] as! Bool == false {
                placeItem(5) }
            else { genItem() }
        }
        if roll >= 21 && roll <= 22 {
            if itemsDisabled[5] as! Bool == false {
                placeItem(6) }
            else { genItem() }
        }
        if roll >= 23 && roll <= 25 {
            if itemsDisabled[6] as! Bool == false {
                placeItem(7) }
            else { genItem() }
        }
        if roll >= 26 && roll <= 29 {
            if itemsDisabled[7] as! Bool == false {
                placeItem(8) }
            else { genItem() }
        }
        
        if globalIsOffense == true {
        if roll >= 30 && roll <= 33 {
            if itemsDisabled[8] as! Bool == false {
                placeItem(9) }
            else { genItem() }
        }
        if roll >= 34 && roll <= 35 {
            if itemsDisabled[9] as! Bool == false {
                placeItem(10) }
            else { genItem() }
        }
        if roll >= 36 && roll <= 38 {
            if itemsDisabled[10] as! Bool == false {
                placeItem(11) }
            else { genItem() }
        }
        if roll == 39 {
            if itemsDisabled[11] as! Bool == false {
                placeItem(12) }
            else { genItem() }
        }
        }
        
        if globalIsOffense == false {
        if roll >= 30 && roll <= 32 {
            if itemsDisabled[12] as! Bool == false {
                placeItem(13) }
            else { genItem() }
        }
        if roll >= 33 && roll <= 35 {
            if itemsDisabled[13] as! Bool == false {
                placeItem(14) }
            else { genItem() }
        }
        if roll >= 36 && roll <= 37 {
            if itemsDisabled[14] as! Bool == false {
                placeItem(15) }
            else { genItem() }
        }
        if roll == 38 {
            if itemsDisabled[15] as! Bool == false {
                placeItem(16) }
            else { genItem() }
        }
        if roll == 39 {
            self.logEvent("Got cash!")
            let roll = Int(arc4random_uniform(10) + 1)
            currentFunds = currentFunds + roll
        }
        }
        
        if roll >= 40 && roll <= 49 {
            self.logEvent("Got cash!")
            let roll = Int(arc4random_uniform(8) + 1)
            currentFunds = currentFunds + roll
        }
        if roll >= 50 && roll <= 55 {
            self.logEvent("Got cash!")
            let roll = Int(arc4random_uniform(20) + 1)
            currentFunds = currentFunds + roll
        }
        
    }
    
    func placeItem(item: Int) {
        if slot1Powerup == 0 {
            self.logEvent("Got an item!")
            slot1Powerup = item
            self.refreshItems()
        }
        else if slot2Powerup == 0 {
            self.logEvent("Got an item!")
            slot2Powerup = item
            self.refreshItems()
        }
        else if slot3Powerup == 0 {
            self.logEvent("Got an item!")
            slot3Powerup = item
            self.refreshItems()
        }
        else {
            self.logEvent("Items full, got cash!")
            let roll = Int(arc4random_uniform(10) + 1)
            currentFunds = currentFunds + roll
            self.refreshItems()
        }
    }
    //dropItem
    func rollItemLocation() {
        
        var xx = drand48()
        let yy = Int(arc4random_uniform(2) + 1)
        if yy == 1 {
            xx = xx * -1
        }
        var aa = drand48()
        let bb = Int(arc4random_uniform(2) + 1)
        if bb == 1 {
            aa = aa * -1
        }
        
        let randLat: Double = Double((xx * self.basePointDistance) + self.mapCenterPointLat)
        let randLatTruncated = String(randLat).trunc(15)
        let randLatTDouble = Double(randLatTruncated)
        let randLong: Double = Double((aa * self.basePointDistance) + self.mapCenterPointLong)
        let randLongTruncated = String(randLong).trunc(15)
        let randLongTDouble = Double(randLongTruncated)
        //self.mapItem(randLatTDouble!, long: randLongTDouble!)
        
        if globalIsOffense == false && self.baseRegion.containsCoordinate(CLLocationCoordinate2D(latitude: randLatTDouble!, longitude: randLongTDouble!)) {
            print("dropped in base region, rerolling..")
            self.rollItemLocation()
        }
        else {
        self.postItem(randLatTDouble!, long: randLongTDouble!)
        }
    }
    
    func mapItem(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        print("map item fired, lat \(lat) long \(long)")
        self.itemdrop?.play()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        if self.drop1Dropped == false || (self.firstDropped != 1 && self.secondDropped != 1 && self.thirdDropped != 1 && self.fourthDropped != 1) {
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.removeOverlay(self.drop1Circle)
            self.drop1Dropped = true
            self.drop1DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop1Coordinates = coord
            self.mapView.addAnnotation(self.drop1DropPin)
            self.drop1Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop1Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.drop1Circle)
            self.fourthDropped = self.thirdDropped
            self.thirdDropped = self.secondDropped
            self.secondDropped = self.firstDropped
            self.firstDropped = 1
            print("drop 1 dropped, lat \(lat) long \(long)")
        }
        else if self.drop2Dropped == false || (self.firstDropped != 2 && self.secondDropped != 2 && self.thirdDropped != 2 && self.fourthDropped != 2) {
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.removeOverlay(self.drop2Circle)
            self.drop2Dropped = true
            self.drop2DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop2Coordinates = coord
            self.mapView.addAnnotation(self.drop2DropPin)
            self.drop2Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop2Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.drop2Circle)
            self.fourthDropped = self.thirdDropped
            self.thirdDropped = self.secondDropped
            self.secondDropped = self.firstDropped
            self.firstDropped = 2
            print("drop 2 dropped, lat \(lat) long \(long)")
        }
        else if self.drop3Dropped == false || (self.firstDropped != 3 && self.secondDropped != 3 && self.thirdDropped != 3 && self.fourthDropped != 3) {
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.removeOverlay(self.drop3Circle)
            self.drop3Dropped = true
            self.drop3DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop3Coordinates = coord
            self.mapView.addAnnotation(self.drop3DropPin)
            self.drop3Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop3Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.drop3Circle)
            self.fourthDropped = self.thirdDropped
            self.thirdDropped = self.secondDropped
            self.secondDropped = self.firstDropped
            self.firstDropped = 3
            print("drop 3 dropped, lat \(lat) long \(long)")
        }
        else if self.drop4Dropped == false || (self.firstDropped != 4 && self.secondDropped != 4 && self.thirdDropped != 4 && self.fourthDropped != 4) {
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.removeOverlay(self.drop4Circle)
            self.drop4Dropped = true
            self.drop4DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop4Coordinates = coord
            self.mapView.addAnnotation(self.drop4DropPin)
            self.drop4Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop4Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.drop4Circle)
            self.fourthDropped = self.thirdDropped
            self.thirdDropped = self.secondDropped
            self.secondDropped = self.firstDropped
            self.firstDropped = 4
            print("drop 4 dropped, lat \(lat) long \(long)")
        }
        else if self.drop5Dropped == false || (self.firstDropped != 5 && self.secondDropped != 5 && self.thirdDropped != 5 && self.fourthDropped != 5) {
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.removeOverlay(self.drop5Circle)
            self.drop5Dropped = true
            self.drop5DropPin = CustomPinDrop(coordinate: coord, title: "Item")
            self.drop5Coordinates = coord
            self.mapView.addAnnotation(self.drop5DropPin)
            self.drop5Region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "")
            self.drop5Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.drop5Circle)
            self.fourthDropped = self.thirdDropped
            self.thirdDropped = self.secondDropped
            self.secondDropped = self.firstDropped
            self.firstDropped = 5
            print("drop 5 dropped, lat \(lat) long \(long)")
        }
    }
    
    func unmapItems() {
        print("unmap items fired")
        if globalIsOffense == true {
        let O1Lat: Double = Double("\(self.OI1[1] as! Double)")!
        let O2Lat: Double = Double("\(self.OI2[1] as! Double)")!
        let O3Lat: Double = Double("\(self.OI3[1] as! Double)")!
        let O4Lat: Double = Double("\(self.OI4[1] as! Double)")!
        let O5Lat: Double = Double("\(self.OI5[1] as! Double)")!
            
//            print("O1 lat \(O1Lat)")
//            print("O2 lat \(O2Lat)")
//            print("O3 lat \(O3Lat)")
//            print("O4 lat \(O4Lat)")
//            print("O5 lat \(O5Lat)")
//            
//            print("pin 1 lat \(self.drop1DropPin.coordinate.latitude)")
//            print("pin 2 lat \(self.drop2DropPin.coordinate.latitude)")
//            print("pin 3 lat \(self.drop3DropPin.coordinate.latitude)")
//            print("pin 4 lat \(self.drop4DropPin.coordinate.latitude)")
//            print("pin 5 lat \(self.drop5DropPin.coordinate.latitude)")
            
            
        
        if self.drop1Dropped == true && self.drop1DropPin.coordinate.latitude != O1Lat && self.drop1DropPin.coordinate.latitude != O2Lat && self.drop1DropPin.coordinate.latitude != O3Lat && self.drop1DropPin.coordinate.latitude != O4Lat && self.drop1DropPin.coordinate.latitude != O5Lat  {
            print("unmap 1 fired")
            self.drop1Dropped = false
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.removeOverlay(self.drop1Circle)
            self.drop1DropPin.coordinate.latitude = 0
        }
        if self.drop2Dropped == true && self.drop2DropPin.coordinate.latitude != O1Lat && self.drop2DropPin.coordinate.latitude != O2Lat && self.drop2DropPin.coordinate.latitude != O3Lat && self.drop2DropPin.coordinate.latitude != O4Lat && self.drop2DropPin.coordinate.latitude != O5Lat  {
            print("unmap 2 fired")
            self.drop2Dropped = false
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.removeOverlay(self.drop2Circle)
            self.drop2DropPin.coordinate.latitude = 0
        }
        if self.drop3Dropped == true && self.drop3DropPin.coordinate.latitude != O1Lat && self.drop3DropPin.coordinate.latitude != O2Lat && self.drop3DropPin.coordinate.latitude != O3Lat && self.drop3DropPin.coordinate.latitude != O4Lat && self.drop3DropPin.coordinate.latitude != O5Lat  {
            print("unmap 3 fired")
            self.drop3Dropped = false
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.removeOverlay(self.drop3Circle)
            self.drop3DropPin.coordinate.latitude = 0
        }
        if self.drop4Dropped == true && self.drop4DropPin.coordinate.latitude != O1Lat && self.drop4DropPin.coordinate.latitude != O2Lat && self.drop4DropPin.coordinate.latitude != O3Lat && self.drop4DropPin.coordinate.latitude != O4Lat && self.drop4DropPin.coordinate.latitude != O5Lat  {
            print("unmap 4 fired")
            self.drop4Dropped = false
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.removeOverlay(self.drop4Circle)
            self.drop4DropPin.coordinate.latitude = 0
        }
        if self.drop5Dropped == true && self.drop5DropPin.coordinate.latitude != O1Lat && self.drop5DropPin.coordinate.latitude != O2Lat && self.drop5DropPin.coordinate.latitude != O3Lat && self.drop5DropPin.coordinate.latitude != O4Lat && self.drop5DropPin.coordinate.latitude != O5Lat  {
            print("unmap 5 fired")
            self.drop5Dropped = false
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.removeOverlay(self.drop5Circle)
            self.drop5DropPin.coordinate.latitude = 0
        }
        }
        if globalIsOffense == false {
            let D1Lat: Double = Double("\(self.DI1[1] as! Double)")!
            let D2Lat: Double = Double("\(self.DI2[1] as! Double)")!
            let D3Lat: Double = Double("\(self.DI3[1] as! Double)")!
            let D4Lat: Double = Double("\(self.DI4[1] as! Double)")!
            let D5Lat: Double = Double("\(self.DI5[1] as! Double)")!
            
            if self.drop1Dropped == true && self.drop1DropPin.coordinate.latitude != D1Lat && self.drop1DropPin.coordinate.latitude != D2Lat && self.drop1DropPin.coordinate.latitude != D3Lat && self.drop1DropPin.coordinate.latitude != D4Lat && self.drop1DropPin.coordinate.latitude != D5Lat  {
                print("unmap 1 fired")
                self.drop1Dropped = false
                self.mapView.removeAnnotation(self.drop1DropPin)
                self.mapView.removeOverlay(self.drop1Circle)
                self.drop1DropPin.coordinate.latitude = 0
            }
            if self.drop2Dropped == true && self.drop2DropPin.coordinate.latitude != D1Lat && self.drop2DropPin.coordinate.latitude != D2Lat && self.drop2DropPin.coordinate.latitude != D3Lat && self.drop2DropPin.coordinate.latitude != D4Lat && self.drop2DropPin.coordinate.latitude != D5Lat  {
                print("unmap 2 fired")
                self.drop2Dropped = false
                self.mapView.removeAnnotation(self.drop2DropPin)
                self.mapView.removeOverlay(self.drop2Circle)
                self.drop2DropPin.coordinate.latitude = 0
            }
            if self.drop3Dropped == true && self.drop3DropPin.coordinate.latitude != D1Lat && self.drop3DropPin.coordinate.latitude != D2Lat && self.drop3DropPin.coordinate.latitude != D3Lat && self.drop3DropPin.coordinate.latitude != D4Lat && self.drop3DropPin.coordinate.latitude != D5Lat  {
                print("unmap 3 fired")
                self.drop3Dropped = false
                self.mapView.removeAnnotation(self.drop3DropPin)
                self.mapView.removeOverlay(self.drop3Circle)
                self.drop3DropPin.coordinate.latitude = 0
            }
            if self.drop4Dropped == true && self.drop4DropPin.coordinate.latitude != D1Lat && self.drop4DropPin.coordinate.latitude != D2Lat && self.drop4DropPin.coordinate.latitude != D3Lat && self.drop4DropPin.coordinate.latitude != D4Lat && self.drop4DropPin.coordinate.latitude != D5Lat  {
                print("unmap 4 fired")
                self.drop4Dropped = false
                self.mapView.removeAnnotation(self.drop4DropPin)
                self.mapView.removeOverlay(self.drop4Circle)
                self.drop4DropPin.coordinate.latitude = 0
            }
            if self.drop5Dropped == true && self.drop5DropPin.coordinate.latitude != D1Lat && self.drop5DropPin.coordinate.latitude != D2Lat && self.drop5DropPin.coordinate.latitude != D3Lat && self.drop5DropPin.coordinate.latitude != D4Lat && self.drop5DropPin.coordinate.latitude != D5Lat  {
                print("unmap 5 fired")
                self.drop5Dropped = false
                self.mapView.removeAnnotation(self.drop5DropPin)
                self.mapView.removeOverlay(self.drop5Circle)
                self.drop5DropPin.coordinate.latitude = 0
            }
            
        }
    }
    
//    func unmapItems2() {
//        
//        print("unmap items 2 fired")
//        print("drop 1 lat \(self.drop1Coordinates.latitude)")
//        print("drop 2 lat \(self.drop2Coordinates.latitude)")
//        print("drop 3 lat \(self.drop3Coordinates.latitude)")
//        print("drop 4 lat \(self.drop4Coordinates.latitude)")
//        print("drop 5 lat \(self.drop5Coordinates.latitude)")
//        
//        
//        //unmap items that were picked up by teammates
//        if self.drop1Coordinates.latitude != 0 && self.drop1Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop1Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//            self.drop1Dropped = false
//            self.mapView.removeAnnotation(self.drop1DropPin)
//            self.mapView.removeOverlay(self.drop1Circle)
//        }
//        if self.drop2Coordinates.latitude != 0 && self.drop2Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop2Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//            self.drop2Dropped = false
//            self.mapView.removeAnnotation(self.drop2DropPin)
//            self.mapView.removeOverlay(self.drop2Circle)
//        }
//        if self.drop3Coordinates.latitude != 0 && self.drop3Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop3Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//            self.drop3Dropped = false
//            self.mapView.removeAnnotation(self.drop3DropPin)
//            self.mapView.removeOverlay(self.drop3Circle)
//        }
//        if self.drop4Coordinates.latitude != 0 && self.drop4Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop4Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//            self.drop4Dropped = false
//            self.mapView.removeAnnotation(self.drop4DropPin)
//            self.mapView.removeOverlay(self.drop4Circle)
//        }
//        if self.drop5Coordinates.latitude != 0 && self.drop5Coordinates.latitude != Double("\(self.DI1[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI2[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI3[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI4[1] as! Double)") && self.drop5Coordinates.latitude != Double("\(self.DI5[1] as! Double)")  {
//            self.drop5Dropped = false
//            self.mapView.removeAnnotation(self.drop5DropPin)
//            self.mapView.removeOverlay(self.drop5Circle)
//        }
//        
//    }
    
//    func unmapItem (lat: Double) {
//
//        if self.drop1Dropped == true && self.drop1DropPin.coordinate.latitude == lat {
//            self.drop1Dropped = false
//            self.mapView.removeAnnotation(self.drop1DropPin)
//            self.mapView.removeOverlay(self.drop1Circle)
//            self.drop1DropPin.coordinate.latitude = 0
//        }
//        if self.drop2Dropped == true && self.drop2DropPin.coordinate.latitude == lat {
//            self.drop2Dropped = false
//            self.mapView.removeAnnotation(self.drop2DropPin)
//            self.mapView.removeOverlay(self.drop2Circle)
//            self.drop2DropPin.coordinate.latitude = 0
//        }
//        if self.drop3Dropped == true && self.drop3DropPin.coordinate.latitude == lat {
//            self.drop3Dropped = false
//            self.mapView.removeAnnotation(self.drop3DropPin)
//            self.mapView.removeOverlay(self.drop3Circle)
//            self.drop3DropPin.coordinate.latitude = 0
//        }
//        if self.drop4Dropped == true && self.drop4DropPin.coordinate.latitude == lat {
//            self.drop4Dropped = false
//            self.mapView.removeAnnotation(self.drop4DropPin)
//            self.mapView.removeOverlay(self.drop4Circle)
//            self.drop4DropPin.coordinate.latitude = 0
//        }
//        if self.drop5Dropped == true && self.drop5DropPin.coordinate.latitude == lat {
//            self.drop5Dropped = false
//            self.mapView.removeAnnotation(self.drop5DropPin)
//            self.mapView.removeOverlay(self.drop5Circle)
//            self.drop5DropPin.coordinate.latitude = 0
//        }
//
//    }

    func postSpybot (lat: Double, long: Double) {
        
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            // 2-1 changed from if error == nil
            if let itemInfo = itemInfo {
                let nonceTemp = Int(arc4random_uniform(999999))
                
                if globalIsOffense == true {
                    if Int("\(self.OS[4] as! Int)") >= Int("\(self.OS2[4] as! Int)") {
                        itemInfo["OS"] = [globalUserName, nonceTemp, lat, long, gameTimerCount]
                    }
                    else  {
                        itemInfo["OS2"] = [globalUserName, nonceTemp, lat, long, gameTimerCount]
                    }
                }
                
                if globalIsOffense == false {
                    if Int("\(self.DS[4] as! Int)") >= Int("\(self.DS2[4] as! Int)") {
                        itemInfo["DS"] = [globalUserName, nonceTemp, lat, long, gameTimerCount]
                    }
                    else  {
                        itemInfo["DS2"] = [globalUserName, nonceTemp, lat, long, gameTimerCount]
                    }
                }
   
                itemInfo.saveEventually()
            }
        }
    }
    
    func postMine (lat: Double, long: Double, isSuper: Bool, nonce: Int) {
        
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            // 2-1 changed from if error == nil
            if let itemInfo = itemInfo {
                
                if globalIsOffense == true {
                    if Int("\(self.OM[4] as! Int)") >= Int("\(self.OM2[4] as! Int)") {
                        itemInfo["OM"] = [globalUserName, nonce, lat, long, gameTimerCount, isSuper]
                    }
                    else  {
                        itemInfo["OM2"] = [globalUserName, nonce, lat, long, gameTimerCount, isSuper]
                    }
                }
                
                if globalIsOffense == false {
                    if Int("\(self.DM[4] as! Int)") >= Int("\(self.DM2[4] as! Int)") {
                        itemInfo["DM"] = [globalUserName, nonce, lat, long, gameTimerCount, isSuper]
                    }
                    else  {
                        itemInfo["DM2"] = [globalUserName, nonce, lat, long, gameTimerCount, isSuper]
                    }
                }
                itemInfo.saveEventually()
            }
        }
    }
    
    func dropMine(lat: Double, long: Double, isSuper: Bool, nonce: Int) {
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        if self.mine1Dropped == false || (self.firstMineDropped != 1 && self.secondMineDropped != 1) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine1Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 1
            self.mine1Nonce = nonce
            
            if isSuper == false {
                self.mine1isSuper = false
                self.mine1DropPin.coordinate = coord
                self.mine1DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine1DropPin)
                self.mine1region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "supermine1region")
                self.mine1Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine1Circle)
            }
            if isSuper == true {
                self.mine1isSuper = true
                self.supermine1DropPin.coordinate = coord
                self.supermine1DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine1DropPin)
                self.mine1region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine1region")
                self.mine1Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine1Circle)
            }
        }
        
        else if self.mine2Dropped == false || (self.firstMineDropped != 2 && self.secondMineDropped != 2) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine2Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 2
            self.mine2Nonce = nonce
            
            if isSuper == false {
                self.mine2isSuper = false
                self.mine2DropPin.coordinate = coord
                self.mine2DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine2DropPin)
                self.mine2region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "supermine2region")
                self.mine2Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine2Circle)
            }
            if isSuper == true {
                self.mine2isSuper = true
                self.supermine2DropPin.coordinate = coord
                self.supermine2DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine2DropPin)
                self.mine2region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine2region")
                self.mine2Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine2Circle)
            }
        }
        
        else if self.mine3Dropped == false || (self.firstMineDropped != 3 && self.secondMineDropped != 3) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine3Dropped = true
            self.secondMineDropped = self.firstMineDropped
            self.firstMineDropped = 3
            self.mine3Nonce = nonce
            
            if isSuper == false {
                self.mine3isSuper = false
                self.mine3DropPin.coordinate = coord
                self.mine3DropPin.title = "Mine"
                self.mapView.addAnnotation(self.mine3DropPin)
                self.mine3region = CLCircularRegion(center: coord, radius: CLLocationDistance(5), identifier: "supermine3region")
                self.mine3Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine3Circle)
            }
            if isSuper == true {
                self.mine3isSuper = true
                self.supermine3DropPin.coordinate = coord
                self.supermine3DropPin.title = "Supermine"
                self.mapView.addAnnotation(self.supermine3DropPin)
                self.mine3region = CLCircularRegion(center: coord, radius: CLLocationDistance(9), identifier: "supermine3region")
                self.mine3Circle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine3Circle)
            }
        }
        
    }
    
    func dropMineView(lat: Double, long: Double, isSuper: Bool, player: String, nonce: Int) {
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        if self.mine1VDropped == false || (self.firstMineVDropped != 1 && self.secondMineVDropped != 1 && self.thirdMineVDropped != 1 && self.fourthMineVDropped != 1) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine1VDropped = true
            self.mine1VNonce = nonce
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine1VDropPin)
            self.mapView.removeAnnotation(self.supermine1VDropPin)
            self.mapView.removeOverlay(self.mine1VCircle)
            
            if isSuper == false {
                self.mine1VisSuper = false
                self.mine1VDropPin.coordinate = coord
                self.mine1VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine1VDropPin)
                self.mine1VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine1VCircle)
            }
            if isSuper == true {
                self.mine1VisSuper = true
                self.supermine1VDropPin.coordinate = coord
                self.supermine1VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine1VDropPin)
                self.mine1VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine1VCircle)
            }
        }
        if self.mine2VDropped == false || (self.firstMineVDropped != 2 && self.secondMineVDropped != 2 && self.thirdMineVDropped != 2 && self.fourthMineVDropped != 2) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine2VDropped = true
            self.mine2VNonce = nonce
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine2VDropPin)
            self.mapView.removeAnnotation(self.supermine2VDropPin)
            self.mapView.removeOverlay(self.mine2VCircle)
            
            if isSuper == false {
                self.mine2VisSuper = false
                self.mine2VDropPin.coordinate = coord
                self.mine2VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine2VDropPin)
                self.mine2VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine2VCircle)
            }
            if isSuper == true {
                self.mine2VisSuper = true
                self.supermine2VDropPin.coordinate = coord
                self.supermine2VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine2VDropPin)
                self.mine2VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine2VCircle)
            }
        }
        if self.mine3VDropped == false || (self.firstMineVDropped != 3 && self.secondMineVDropped != 3 && self.thirdMineVDropped != 3 && self.fourthMineVDropped != 3) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine3VDropped = true
            self.mine3VNonce = nonce
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine3VDropPin)
            self.mapView.removeAnnotation(self.supermine3VDropPin)
            self.mapView.removeOverlay(self.mine3VCircle)
            
            if isSuper == false {
                self.mine3VisSuper = false
                self.mine3VDropPin.coordinate = coord
                self.mine3VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine3VDropPin)
                self.mine3VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine3VCircle)
            }
            if isSuper == true {
                self.mine3VisSuper = true
                self.supermine3VDropPin.coordinate = coord
                self.supermine3VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine3VDropPin)
                self.mine3VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine3VCircle)
            }
        }
        if self.mine4VDropped == false || (self.firstMineVDropped != 4 && self.secondMineVDropped != 4 && self.thirdMineVDropped != 4 && self.fourthMineVDropped != 4) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine4VDropped = true
            self.mine4VNonce = nonce
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine4VDropPin)
            self.mapView.removeAnnotation(self.supermine4VDropPin)
            self.mapView.removeOverlay(self.mine4VCircle)
            
            if isSuper == false {
                self.mine4VisSuper = false
                self.mine4VDropPin.coordinate = coord
                self.mine4VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine4VDropPin)
                self.mine4VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine4VCircle)
            }
            if isSuper == true {
                self.mine4VisSuper = true
                self.supermine4VDropPin.coordinate = coord
                self.supermine4VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine4VDropPin)
                self.mine4VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine4VCircle)
            }
        }
        if self.mine5VDropped == false || (self.firstMineVDropped != 5 && self.secondMineVDropped != 5 && self.thirdMineVDropped != 5 && self.fourthMineVDropped != 5) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.setmine?.play()
            self.mine5VDropped = true
            self.mine5VNonce = nonce
            self.fourthMineVDropped = self.thirdMineVDropped
            self.thirdMineVDropped = self.secondMineVDropped
            self.secondMineVDropped = self.firstMineVDropped
            self.firstMineVDropped = 1
            self.mapView.removeAnnotation(self.mine5VDropPin)
            self.mapView.removeAnnotation(self.supermine5VDropPin)
            self.mapView.removeOverlay(self.mine5VCircle)
            
            if isSuper == false {
                self.mine5VisSuper = false
                self.mine5VDropPin.coordinate = coord
                self.mine5VDropPin.title = "\(player)'s mine"
                self.mapView.addAnnotation(self.mine5VDropPin)
                self.mine5VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(5))
                self.mapView.addOverlay(self.mine5VCircle)
            }
            if isSuper == true {
                self.mine5VisSuper = true
                self.supermine5VDropPin.coordinate = coord
                self.supermine5VDropPin.title = "\(player)'s supermine"
                self.mapView.addAnnotation(self.supermine5VDropPin)
                self.mine5VCircle = MKCircle(centerCoordinate: coord, radius: CLLocationDistance(9))
                self.mapView.addOverlay(self.mine5VCircle)
            }
        }
    }
    
    func unpostMine (nonce: Int) {
        
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            // 2-1 changed from if error == nil
            if let itemInfo = itemInfo {
                
                if globalIsOffense == true {
                    if Int("\(self.OMU[1] as! Int)") >= Int("\(self.OMU2[1] as! Int)") {
                        itemInfo["OMU"] = [nonce, gameTimerCount]
                    }
                    else  {
                        itemInfo["OMU2"] = [nonce, gameTimerCount]
                    }
                }
                
                if globalIsOffense == false {
                    if Int("\(self.DMU[1] as! Int)") >= Int("\(self.DMU2[1] as! Int)") {
                        itemInfo["DMU"] = [nonce, gameTimerCount]
                    }
                    else  {
                        itemInfo["DMU2"] = [nonce, gameTimerCount]
                    }
                }
                itemInfo.saveEventually()
            }
        }
    }
    
    
    
    func postItem(lat: Double, long: Double) {
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            // 2-1 changed from if error == nil
            if let itemInfo = itemInfo {
                if globalIsOffense == true {
                    
                    if Int("\(self.OI1[0] as! Int)") == 0 {
                        itemInfo["OI1"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.OI2[0] as! Int)") == 0 {
                        itemInfo["OI2"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.OI3[0] as! Int)") == 0 {
                        itemInfo["OI3"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.OI4[0] as! Int)") == 0 {
                        itemInfo["OI4"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.OI5[0] as! Int)") == 0 {
                        itemInfo["OI5"] = [gameTimerCount,lat,long]
                    }
                    else {
                        if Int("\(self.OI1[0] as! Int)") >= Int("\(self.OI2[0] as! Int)") && Int("\(self.OI1[0] as! Int)") >= Int("\(self.OI3[0] as! Int)") && Int("\(self.OI1[0] as! Int)") >= Int("\(self.OI4[0] as! Int)") && Int("\(self.OI1[0] as! Int)") >= Int("\(self.OI5[0] as! Int)") {
                                itemInfo["OI1"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.OI2[0] as! Int)") >= Int("\(self.OI3[0] as! Int)") && Int("\(self.OI2[0] as! Int)") >= Int("\(self.OI4[0] as! Int)") && Int("\(self.OI2[0] as! Int)") >= Int("\(self.OI5[0] as! Int)") {
                                itemInfo["OI2"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.OI3[0] as! Int)") >= Int("\(self.OI4[0] as! Int)") && Int("\(self.OI3[0] as! Int)") >= Int("\(self.OI5[0] as! Int)") {
                                itemInfo["OI3"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.OI4[0] as! Int)") >= Int("\(self.OI5[0] as! Int)") {
                                itemInfo["OI4"] = [gameTimerCount,lat,long]
                        }
                        else {
                                itemInfo["OI5"] = [gameTimerCount,lat,long]
                        }
                    }
                    

                }
                if globalIsOffense == false {
                    if Int("\(self.DI1[0] as! Int)") == 0 {
                        itemInfo["DI1"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.DI2[0] as! Int)") == 0 {
                        itemInfo["DI2"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.DI3[0] as! Int)") == 0 {
                        itemInfo["DI3"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.DI4[0] as! Int)") == 0 {
                        itemInfo["DI4"] = [gameTimerCount,lat,long]
                    }
                    else if Int("\(self.DI5[0] as! Int)") == 0 {
                        itemInfo["DI5"] = [gameTimerCount,lat,long]
                    }
                    else {
                        if Int("\(self.DI1[0] as! Int)") >= Int("\(self.DI2[0] as! Int)") && Int("\(self.DI1[0] as! Int)") >= Int("\(self.DI3[0] as! Int)") && Int("\(self.DI1[0] as! Int)") >= Int("\(self.DI4[0] as! Int)") && Int("\(self.DI1[0] as! Int)") >= Int("\(self.DI5[0] as! Int)") {
                            itemInfo["DI1"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.DI2[0] as! Int)") >= Int("\(self.DI3[0] as! Int)") && Int("\(self.DI2[0] as! Int)") >= Int("\(self.DI4[0] as! Int)") && Int("\(self.DI2[0] as! Int)") >= Int("\(self.DI5[0] as! Int)") {
                            itemInfo["DI2"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.DI3[0] as! Int)") >= Int("\(self.DI4[0] as! Int)") && Int("\(self.DI3[0] as! Int)") >= Int("\(self.DI5[0] as! Int)") {
                            itemInfo["DI3"] = [gameTimerCount,lat,long]
                        }
                        else if Int("\(self.DI4[0] as! Int)") >= Int("\(self.DI5[0] as! Int)") {
                            itemInfo["DI4"] = [gameTimerCount,lat,long]
                        }
                        else {
                            itemInfo["DI5"] = [gameTimerCount,lat,long]
                        }
                    }
                }
                itemInfo.saveEventually()
            }
        }
    }
    
    func unpostItem(lat: Double) {
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            if let itemInfo = itemInfo {
                if globalIsOffense == true {
                    
                    if Double("\(self.OI1[1] as! Double)") == lat {
                        self.OI1 = [0,0,0]
                        itemInfo["OI1"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.OI2[1] as! Double)") == lat {
                        self.OI2 = [0,0,0]
                        itemInfo["OI2"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.OI3[1] as! Double)") == lat {
                        self.OI3 = [0,0,0]
                        itemInfo["OI3"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.OI4[1] as! Double)") == lat {
                        self.OI4 = [0,0,0]
                        itemInfo["OI4"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.OI5[1] as! Double)") == lat {
                        self.OI5 = [0,0,0]
                        itemInfo["OI5"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                }
                if globalIsOffense == false {
                    if Double("\(self.DI1[1] as! Double)") == lat {
                        self.DI1 = [0,0,0]
                        itemInfo["DI1"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.DI2[1] as! Double)") == lat {
                        self.DI2 = [0,0,0]
                        itemInfo["DI2"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.DI3[1] as! Double)") == lat {
                        self.DI3 = [0,0,0]
                        itemInfo["DI3"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.DI4[1] as! Double)") == lat {
                        self.DI4 = [0,0,0]
                        itemInfo["DI4"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                    else if Double("\(self.DI5[1] as! Double)") == lat {
                        self.DI5 = [0,0,0]
                        itemInfo["DI5"] = [0,0,0]
                        itemInfo.saveEventually()
                    }
                }
            }
        }
    }
    
    func logEvent(event: String) {
        self.eventsLabel.text = event
        eventsArray.insert(event, atIndex: 0)
        eventsArray.insert(String(gameTimerCount), atIndex: 0)
        if eventsArray.count >= 25 {
            eventsArray.removeAtIndex(25)
            eventsArray.removeAtIndex(24)
        }
    }
    
    
    func postTag (tagger: String, tagee: String, method: Int, nonce: Int, hadFlag: Bool) {
        
        let localPlayerCapturingPointTemp = self.localPlayerCapturingPoint
        let localPlayerCapturedPointTemp = self.localPlayerCapturedPoint
        
        inGameInfo.fetchInBackgroundWithBlock {
            (inGameInfo: PFObject?, error: NSError?) -> Void in
            if let inGameInfo = inGameInfo {
                    if Int("\(self.T[4] as! Int)") >= Int("\(self.T2[4] as! Int)") {
                        inGameInfo["T"] = [tagger, tagee, method, nonce, gameTimerCount, hadFlag]
                        print(inGameInfo["T"])
                    }
                    else  {
                        inGameInfo["T2"] = [tagger, tagee, method, nonce, gameTimerCount, hadFlag]
                        print(inGameInfo["T2"])
                    }
                
            
            //added 2-11 to fix tag posting issue
                if localPlayerCapturingPointTemp == true || localPlayerCapturedPointTemp == true {
                            
                            if localPlayerCapturedPointTemp == true {
                                self.randomPlayerWithPointTagged = String(arc4random_uniform(999999))
                                inGameInfo["randomPlayerWithPointTagged"] = self.randomPlayerWithPointTagged
                                inGameInfo["playerWithPointTaggedName"] = globalUserName
                            }
                            
                            inGameInfo["playerCapturingPoint"] = "n"
                            inGameInfo["playerCapturedPoint"] = "n"
                            inGameInfo["playerCapturingPointPosition"] = "n"
                            inGameInfo["playerCapturedPointPosition"] = "n"
                            
                }
                
                print("post tag save fired")
                inGameInfo.saveEventually()
            }
        }
    }
    
    func postMineTag(tagger: String, inbox: String) {
        
        print("postMineTag fired")
        print("tagged: \(tagger)")
        print("inbox: \(inbox)")
        
        itemInfo.fetchInBackgroundWithBlock {
            (itemInfo: PFObject?, error: NSError?) -> Void in
            if let itemInfo = itemInfo {
        let nonceTemp = Int(arc4random_uniform(999999))
        if globalIsOffense == false {
        if inbox == "offense1Inbox" {
           itemInfo["offense1Inbox"] = [3,tagger,nonceTemp]
            print("fired 1 ABC!")
        }
        else if inbox == "offense2Inbox" {
            itemInfo["offense2Inbox"] = [3,tagger,nonceTemp]
            }
        else if inbox == "offense3Inbox" {
            itemInfo["offense3Inbox"] = [3,tagger,nonceTemp]
            }
        else if inbox == "offense4Inbox" {
            itemInfo["offense4Inbox"] = [3,tagger,nonceTemp]
            }
        else if inbox == "offense5Inbox" {
            itemInfo["offense5Inbox"] = [3,tagger,nonceTemp]
            }
        
        }
        else {
            if inbox == "defense1Inbox" {
                itemInfo["defense1Inbox"] = [3,tagger,nonceTemp]
                print("fired 2 ABC!")
            }
            else if inbox == "defense2Inbox" {
                itemInfo["defense2Inbox"] = [3,tagger,nonceTemp]
            }
            if inbox == "defense3Inbox" {
                itemInfo["defense3Inbox"] = [3,tagger,nonceTemp]
            }
            if inbox == "defense4Inbox" {
                itemInfo["defense4Inbox"] = [3,tagger,nonceTemp]
            }
            if inbox == "defense5Inbox" {
                itemInfo["defense5Inbox"] = [3,tagger,nonceTemp]
            }
        }
                print("item info object:")
                print(itemInfo)
                self.itemInfo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    }
                    else {
                        print("saved successfully !! :) :) ")
                        print("self.iteminfo: \(self.itemInfo)")
                        
                        itemInfo.fetchInBackgroundWithBlock {
                            (itemInfo: PFObject?, error: NSError?) -> Void in
                            if let itemInfo = itemInfo {
                                
                                if inbox == "offense1Inbox" {
                                    self.offense1Inbox = itemInfo.objectForKey("offense1Inbox") as! NSArray
                                    if String("\(self.offense1Inbox[1] as! String)") != tagger {
                                        itemInfo["offense1Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "offense2Inbox" {
                                    self.offense2Inbox = itemInfo.objectForKey("offense2Inbox") as! NSArray
                                    if String("\(self.offense2Inbox[1] as! String)") != tagger {
                                        itemInfo["offense2Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "offense3Inbox" {
                                    self.offense3Inbox = itemInfo.objectForKey("offense3Inbox") as! NSArray
                                    if String("\(self.offense3Inbox[1] as! String)") != tagger {
                                        itemInfo["offense3Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "offense4Inbox" {
                                    self.offense4Inbox = itemInfo.objectForKey("offense4Inbox") as! NSArray
                                    if String("\(self.offense4Inbox[1] as! String)") != tagger {
                                        itemInfo["offense4Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "offense5Inbox" {
                                    self.offense5Inbox = itemInfo.objectForKey("offense5Inbox") as! NSArray
                                    if String("\(self.offense5Inbox[1] as! String)") != tagger {
                                        itemInfo["offense5Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "defense1Inbox" {
                                    self.defense1Inbox = itemInfo.objectForKey("defense1Inbox") as! NSArray
                                    if String("\(self.defense1Inbox[1] as! String)") != tagger {
                                        itemInfo["defense1Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "defense2Inbox" {
                                    self.defense2Inbox = itemInfo.objectForKey("defense2Inbox") as! NSArray
                                    if String("\(self.defense2Inbox[1] as! String)") != tagger {
                                        itemInfo["defense2Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "defense3Inbox" {
                                    self.defense3Inbox = itemInfo.objectForKey("defense3Inbox") as! NSArray
                                    if String("\(self.defense3Inbox[1] as! String)") != tagger {
                                        itemInfo["defense3Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "defense4Inbox" {
                                    self.defense4Inbox = itemInfo.objectForKey("defense4Inbox") as! NSArray
                                    if String("\(self.defense4Inbox[1] as! String)") != tagger {
                                        itemInfo["defense4Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                if inbox == "defense5Inbox" {
                                    self.defense5Inbox = itemInfo.objectForKey("defense5Inbox") as! NSArray
                                    if String("\(self.defense5Inbox[1] as! String)") != tagger {
                                        itemInfo["defense5Inbox"] = [3,tagger,nonceTemp]
                                        print("fired 1 ABC232343223r32!")
                                        itemInfo.saveEventually()
                                    }
                                }
                                

                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func reportTag() {

        if String("\(self.T[1] as! String)") != globalUserName && Int("\(self.T[3] as! Int)")! != self.tagNonce1 && Int("\(self.T[3] as! Int)") != self.tagNonce2 && Int("\(self.T[3] as! Int)") != self.tagNonce3 && Int("\(self.T[3] as! Int)") != 0 {
            self.tagNonce3 = self.tagNonce2
            self.tagNonce2 = self.tagNonce1
            self.tagNonce1 = Int("\(self.T[3] as! Int)")!
            
            var relevant = false
            var sound = 0
            
            //standard tag
            if String("\(self.T[0] as! String)") == globalUserName && Int("\(self.T[2] as! Int)") == 0 {
                relevant = true
                playerTagCount++
                if self.T[5] as! Bool == false {
                self.logEvent("You tagged \(self.T[1] as! String)!")
                    self.revealTagee(self.T[1] as! String)                }
                else {
                self.logEvent("You tagged \(self.T[1] as! String), flag returned!")
                    self.revealTagee(self.T[1] as! String)
                sound = 1
                }
            }
            else if String("\(self.T[0] as! String)") != globalUserName && Int("\(self.T[2] as! Int)") == 0 {
                relevant = true
                if self.T[5] as! Bool == false {
                self.logEvent("\(self.T[0] as! String) tagged \(self.T[1] as! String)")
                    self.revealTagee(self.T[1] as! String)
                }
                else {
                self.logEvent("\(self.T[0] as! String) tagged \(self.T[1] as! String), flag returned!")
                    self.revealTagee(self.T[1] as! String)
                sound = 1
                }
            }
            
            //mine tag
            else if String("\(self.T[0] as! String)") != globalUserName && String("\(self.T[1] as! String)") != globalUserName && Int("\(self.T[2] as! Int)") == 1 {
                relevant = true
                if self.T[5] as! Bool == false {
                self.logEvent("\(self.T[0] as! String)'s mine tagged \(self.T[1] as! String)")
                    self.revealTagee(self.T[1] as! String)
                }
                else {
                self.logEvent("\(self.T[0] as! String)'s mine tagged \(self.T[1] as! String), flag returned!")
                    self.revealTagee(self.T[1] as! String)
                sound = 1
                }
            }
            
            //bomb tag
            else if String("\(self.T[0] as! String)") != globalUserName && String("\(self.T[1] as! String)") != globalUserName && Int("\(self.T[2] as! Int)") == 2 {
                relevant = true
                if self.T[5] as! Bool == false {
                self.logEvent("\(self.T[0] as! String)'s bomb tagged \(self.T[1] as! String)")
                    self.revealTagee(self.T[1] as! String)
                }
                else {
                self.logEvent("\(self.T[0] as! String)'s bomb tagged \(self.T[1] as! String), flag returned!")
                    self.revealTagee(self.T[1] as! String)
                sound = 1
                }
            }
            
            //sickle tag
            else if String("\(self.T[0] as! String)") != globalUserName && String("\(self.T[1] as! String)") != globalUserName && Int("\(self.T[2] as! Int)") == 3 {
                relevant = true
                if self.T[5] as! Bool == false {
                self.logEvent("\(self.T[0] as! String)'s sickle tagged \(self.T[1] as! String)!")
                    self.revealTagee(self.T[1] as! String)
                }
                else {
                self.logEvent("\(self.T[0] as! String)'s sickle tagged \(self.T[1] as! String), flag returned!")
                    self.revealTagee(self.T[1] as! String)
                sound = 1
                }
            }
            
            //lightning tag
            else if globalIsOffense == false && String("\(self.T[0] as! String)") != globalUserName && String("\(self.T[1] as! String)") != globalUserName && Int("\(self.T[2] as! Int)") == 4 {
                self.logEvent("\(self.T[0] as! String)'s lightning tagged all opponents!")
                sound = 2
                
                self.lightningScan()
                self.lightningScanCount = 1
                
                self.tagSound(String("\(self.T[1] as! String)"), sound: sound)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }

            if relevant == true {
            self.revealTagee(String("\(self.T[1] as! String)"))
            }
        }
        
        if String("\(self.T2[1] as! String)") != globalUserName && Int("\(self.T2[3] as! Int)")! != self.tagNonce1 && Int("\(self.T2[3] as! Int)") != self.tagNonce2 && Int("\(self.T2[3] as! Int)") != self.tagNonce3 && Int("\(self.T2[3] as! Int)") != 0 {
            self.tagNonce3 = self.tagNonce2
            self.tagNonce2 = self.tagNonce1
            self.tagNonce1 = Int("\(self.T2[3] as! Int)")!
            
            var relevant = false
            var sound = 0
            
            //standard tag
            if String("\(self.T2[0] as! String)") == globalUserName && Int("\(self.T2[2] as! Int)") == 0 {
                relevant = true
                playerTagCount++
                if self.T2[5] as! Bool == false {
                    self.logEvent("You tagged \(self.T2[1] as! String)!")
                }
                else {
                    self.logEvent("You tagged \(self.T2[1] as! String), flag returned!")
                    sound = 1
                }
            }
            else if String("\(self.T2[0] as! String)") != globalUserName && Int("\(self.T2[2] as! Int)") == 0 {
                relevant = true
                if self.T2[5] as! Bool == false {
                    self.logEvent("\(self.T2[0] as! String) tagged \(self.T2[1] as! String)")
                }
                else {
                    self.logEvent("\(self.T2[0] as! String) tagged \(self.T2[1] as! String), flag returned!")
                    sound = 1
                }
            }
                
                //mine tag
            else if String("\(self.T2[0] as! String)") != globalUserName && String("\(self.T2[1] as! String)") != globalUserName && Int("\(self.T2[2] as! Int)") == 1 {
                relevant = true
                if self.T2[5] as! Bool == false {
                    self.logEvent("\(self.T2[0] as! String)'s mine tagged \(self.T2[1] as! String)")
                }
                else {
                    self.logEvent("\(self.T2[0] as! String)'s mine tagged \(self.T2[1] as! String), flag returned!")
                    sound = 1
                }
            }
                
                //bomb tag
            else if String("\(self.T2[0] as! String)") != globalUserName && String("\(self.T2[1] as! String)") != globalUserName && Int("\(self.T2[2] as! Int)") == 2 {
                relevant = true
                if self.T2[5] as! Bool == false {
                    self.logEvent("\(self.T2[0] as! String)'s bomb tagged \(self.T2[1] as! String)")
                }
                else {
                    self.logEvent("\(self.T2[0] as! String)'s bomb tagged \(self.T2[1] as! String), flag returned!")
                    sound = 1
                }
            }
                
                //sickle tag
            else if String("\(self.T2[0] as! String)") != globalUserName && String("\(self.T2[1] as! String)") != globalUserName && Int("\(self.T2[2] as! Int)") == 3 {
                relevant = true
                if self.T2[5] as! Bool == false {
                    self.logEvent("\(self.T2[0] as! String)'s sickle tagged \(self.T2[1] as! String)!")
                }
                else {
                    self.logEvent("\(self.T2[0] as! String)'s sickle tagged \(self.T2[1] as! String), flag returned!")
                    sound = 1
                }
            }
                
                //lightning tag
            else if globalIsOffense == false && String("\(self.T2[0] as! String)") != globalUserName && String("\(self.T2[1] as! String)") != globalUserName && Int("\(self.T2[2] as! Int)") == 4 {
                self.logEvent("\(self.T2[0] as! String)'s lightning tagged all opponents!")
                relevant = true
                sound = 2
            }
            
            if relevant == true {
                self.revealTagee(String("\(self.T2[1] as! String)"))
                self.tagSound(String("\(self.T2[1] as! String)"), sound: sound)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
    
    func tagSound(tagee: String, sound: Int) {
        
        if globalIsOffense == true && sound == 0 && (offense1var == tagee || offense2var == tagee || offense3var == tagee || offense4var == tagee || offense5var == tagee) {
            self.logicCancel?.play()
            }
        else if globalIsOffense == false && sound == 0 && (offense1var == tagee || offense2var == tagee || offense3var == tagee || offense4var == tagee || offense5var == tagee) {
            self.logicGotTag?.play()
        }
        else if globalIsOffense == true && sound == 0 && (defense1var == tagee || defense2var == tagee || defense3var == tagee || defense4var == tagee || defense5var == tagee) {
            self.logicGotTag?.play()
        }
        else if globalIsOffense == false && sound == 0 && (defense1var == tagee || defense2var == tagee || defense3var == tagee || defense4var == tagee || defense5var == tagee) {
            self.logicCancel?.play()
        }
        else if sound == 1 && globalIsOffense == true  {
            self.logicSFX4?.play()
        }
        else if sound == 1 && globalIsOffense == true  {
            self.logicReign?.play()
        }
        else if sound == 2 {
            self.lightning?.play()
        }
    }

    
    func revealTagee(tagee: String) {
        print("reveal tagee fired \(tagee)")
            if tagee == defense1var {
                self.mapView.removeAnnotation(self.defense1DropPin)
                self.mapView.removeAnnotation(self.defense1XDropPin)
                self.mapView.addAnnotation(self.defense1XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 6
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 6
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 6
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == defense2var {
                self.mapView.removeAnnotation(self.defense2DropPin)
                self.mapView.removeAnnotation(self.defense2XDropPin)
                self.mapView.addAnnotation(self.defense2XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 7
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 7
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 7
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == defense3var {
                self.mapView.removeAnnotation(self.defense3DropPin)
                self.mapView.removeAnnotation(self.defense3XDropPin)
                self.mapView.addAnnotation(self.defense3XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 8
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 8
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 8
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == defense4var {
                self.mapView.removeAnnotation(self.defense4DropPin)
                self.mapView.removeAnnotation(self.defense4XDropPin)
                self.mapView.addAnnotation(self.defense4XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 9
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 9
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 9
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == defense5var {
                self.mapView.removeAnnotation(self.defense5DropPin)
                self.mapView.removeAnnotation(self.defense5XDropPin)
                self.mapView.addAnnotation(self.defense5XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 10
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 10
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 10
                        self.revealTagee3Count = 1
                    }
            }
        
            else if tagee == offense1var {
                self.mapView.removeAnnotation(self.offense1DropPin)
                self.mapView.removeAnnotation(self.offense1XDropPin)
                self.mapView.removeAnnotation(self.offense1flagDropPin)
                self.mapView.addAnnotation(self.offense1XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 1
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 1
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 1
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == offense2var {
                self.mapView.removeAnnotation(self.offense2DropPin)
                self.mapView.removeAnnotation(self.offense2XDropPin)
                self.mapView.removeAnnotation(self.offense2flagDropPin)
                self.mapView.addAnnotation(self.offense2XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 2
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 2
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 2
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == offense3var {
                self.mapView.removeAnnotation(self.offense3DropPin)
                self.mapView.removeAnnotation(self.offense3XDropPin)
                self.mapView.removeAnnotation(self.offense3flagDropPin)
                self.mapView.addAnnotation(self.offense3XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 3
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 3
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 3
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == offense4var {
                self.mapView.removeAnnotation(self.offense4DropPin)
                self.mapView.removeAnnotation(self.offense4XDropPin)
                self.mapView.removeAnnotation(self.offense4flagDropPin)
                self.mapView.addAnnotation(self.offense4XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 4
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 4
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 4
                        self.revealTagee3Count = 1
                    }
            }
            else if tagee == offense5var {
                self.mapView.removeAnnotation(self.offense5DropPin)
                self.mapView.removeAnnotation(self.offense5XDropPin)
                self.mapView.removeAnnotation(self.offense5flagDropPin)
                self.mapView.addAnnotation(self.offense5XDropPin)
                    if self.revealTagee1Count == 0 {
                        self.revealTagee1 = 5
                        self.revealTagee1Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee2 = 5
                        self.revealTagee2Count = 1
                    }
                    else if self.revealTagee2Count == 0 {
                        self.revealTagee3 = 5
                        self.revealTagee3Count = 1
                    }
                }
    }
    
    func revealTageeRefire(tageeInt: Int) {
        print("reveal tagee refire fired \(tageeInt)")
        if tageeInt == 6 {
            self.mapView.removeAnnotation(self.defense1DropPin)
            self.mapView.removeAnnotation(self.defense1XDropPin)
            self.mapView.addAnnotation(self.defense1XDropPin)
        }
        else if tageeInt == 7 {
            self.mapView.removeAnnotation(self.defense2DropPin)
            self.mapView.removeAnnotation(self.defense2XDropPin)
            self.mapView.addAnnotation(self.defense2XDropPin)
        }
        else if tageeInt == 8 {
            self.mapView.removeAnnotation(self.defense3DropPin)
            self.mapView.removeAnnotation(self.defense3XDropPin)
            self.mapView.addAnnotation(self.defense3XDropPin)
        }
        else if tageeInt == 9 {
            self.mapView.removeAnnotation(self.defense4DropPin)
            self.mapView.removeAnnotation(self.defense4XDropPin)
            self.mapView.addAnnotation(self.defense4XDropPin)
        }
        else if tageeInt == 10 {
            self.mapView.removeAnnotation(self.defense5DropPin)
            self.mapView.removeAnnotation(self.defense5XDropPin)
            self.mapView.addAnnotation(self.defense5XDropPin)
        }
        
        else if tageeInt == 1 {
            self.mapView.removeAnnotation(self.offense1DropPin)
            self.mapView.removeAnnotation(self.offense1XDropPin)
            self.mapView.removeAnnotation(self.offense1flagDropPin)
            self.mapView.addAnnotation(self.offense1XDropPin)
        }
        else if tageeInt == 2 {
            self.mapView.removeAnnotation(self.offense2DropPin)
            self.mapView.removeAnnotation(self.offense2XDropPin)
            self.mapView.removeAnnotation(self.offense2flagDropPin)
            self.mapView.addAnnotation(self.offense2XDropPin)
        }
        else if tageeInt == 3 {
            self.mapView.removeAnnotation(self.offense3DropPin)
            self.mapView.removeAnnotation(self.offense3XDropPin)
            self.mapView.removeAnnotation(self.offense3flagDropPin)
            self.mapView.addAnnotation(self.offense3XDropPin)
        }
        else if tageeInt == 4 {
            self.mapView.removeAnnotation(self.offense4DropPin)
            self.mapView.removeAnnotation(self.offense4XDropPin)
            self.mapView.removeAnnotation(self.offense4flagDropPin)
            self.mapView.addAnnotation(self.offense4XDropPin)
        }
        else if tageeInt == 5 {
            self.mapView.removeAnnotation(self.offense5DropPin)
            self.mapView.removeAnnotation(self.offense5XDropPin)
            self.mapView.removeAnnotation(self.offense5flagDropPin)
            self.mapView.addAnnotation(self.offense5XDropPin)
        }
    }
    
    func addActiveItemImageView(item: Int) {
        
        if activeItemImageView.hidden == true {
            if item == 7 {
                self.activeItemImageView.image = UIImage(named:"jammer.png")
                self.activeItemImageView.hidden = false
            }
            else if item == 12 {
                self.activeItemImageView.image = UIImage(named:"ghost.png")
                self.activeItemImageView.hidden = false
            }
            else if item == 13 {
                self.activeItemImageView.image = UIImage(named:"reach.png")
                self.activeItemImageView.hidden = false
            }
            else if item == 14 {
                self.activeItemImageView.image = UIImage(named:"fist.png")
                self.activeItemImageView.hidden = false
            }
        }
        else if activeItemImageView2.hidden == true {
            if item == 7 {
                self.activeItemImageView2.image = UIImage(named:"jammer.png")
                self.activeItemImageView2.hidden = false
            }
            else if item == 12 {
                self.activeItemImageView2.image = UIImage(named:"ghost.png")
                self.activeItemImageView2.hidden = false
            }
            else if item == 13 {
                self.activeItemImageView2.image = UIImage(named:"reach.png")
                self.activeItemImageView2.hidden = false
            }
            else if item == 14 {
                self.activeItemImageView2.image = UIImage(named:"fist.png")
                self.activeItemImageView2.hidden = false
            }
        }
        else if activeItemImageView3.hidden == true {
            if item == 7 {
                self.activeItemImageView3.image = UIImage(named:"jammer.png")
                self.activeItemImageView3.hidden = false
            }
            else if item == 12 {
                self.activeItemImageView3.image = UIImage(named:"ghost.png")
                self.activeItemImageView3.hidden = false
            }
            else if item == 13 {
                self.activeItemImageView3.image = UIImage(named:"reach.png")
                self.activeItemImageView3.hidden = false
            }
            else if item == 14 {
                self.activeItemImageView3.image = UIImage(named:"fist.png")
                self.activeItemImageView3.hidden = false
            }
        }
        
    }
    
    func removeActiveItemImageView(item: Int) {
        if item == 7 {
            if self.activeItemImageView.hidden == false && self.activeItemImageView.image == UIImage(named:"jammer.png") {
                self.activeItemImageView.hidden = true
            }
            if self.activeItemImageView2.hidden == false && self.activeItemImageView2.image == UIImage(named:"jammer.png") {
                self.activeItemImageView2.hidden = true
            }
            if self.activeItemImageView3.hidden == false && self.activeItemImageView3.image == UIImage(named:"jammer.png") {
                self.activeItemImageView3.hidden = true
            }
        }
        else if item == 12 {
            if self.activeItemImageView.hidden == false && self.activeItemImageView.image == UIImage(named:"ghost.png") {
                self.activeItemImageView.hidden = true
            }
            if self.activeItemImageView2.hidden == false && self.activeItemImageView2.image == UIImage(named:"ghost.png") {
                self.activeItemImageView2.hidden = true
            }
            if self.activeItemImageView3.hidden == false && self.activeItemImageView3.image == UIImage(named:"ghost.png") {
                self.activeItemImageView3.hidden = true
            }
        }
        else if item == 13 {
            if self.activeItemImageView.hidden == false && self.activeItemImageView.image == UIImage(named:"reach.png") {
                self.activeItemImageView.hidden = true
            }
            if self.activeItemImageView2.hidden == false && self.activeItemImageView2.image == UIImage(named:"reach.png") {
                self.activeItemImageView2.hidden = true
            }
            if self.activeItemImageView3.hidden == false && self.activeItemImageView3.image == UIImage(named:"reach.png") {
                self.activeItemImageView3.hidden = true
            }
        }
        else if item == 14 {
            if self.activeItemImageView.hidden == false && self.activeItemImageView.image == UIImage(named:"fist.png") {
                self.activeItemImageView.hidden = true
            }
            if self.activeItemImageView2.hidden == false && self.activeItemImageView2.image == UIImage(named:"fist.png") {
                self.activeItemImageView2.hidden = true
            }
            if self.activeItemImageView3.hidden == false && self.activeItemImageView3.image == UIImage(named:"fist.png") {
                self.activeItemImageView3.hidden = true
            }
        }
        
        if self.activeItemImageView.hidden == true && self.activeItemImageView2.hidden == false {
            self.activeItemImageView.image = self.activeItemImageView2.image
            self.activeItemImageView.hidden = false
            self.activeItemImageView2.hidden = true
        }
        if self.activeItemImageView2.hidden == true && self.activeItemImageView3.hidden == false {
            self.activeItemImageView2.image = self.activeItemImageView3.image
            self.activeItemImageView2.hidden = false
            self.activeItemImageView3.hidden = true
        }
        if self.activeItemImageView.hidden == true && self.activeItemImageView2.hidden == true && self.activeItemImageView3.hidden == false {
            self.activeItemImageView.image = self.activeItemImageView3.image
            self.activeItemImageView.hidden = false
            self.activeItemImageView3.hidden = true
        }

        
    }

    @IBOutlet var testButton2Outlet: UIButton!
    @IBAction func testButton2(sender: AnyObject) {
        
        let screenCoordinate = mapView.centerCoordinate
        print(screenCoordinate)
        print("test ann type \(testAnnType)")
        print("test ann caption \(testAnnCaption)")
    
        if testAnnType == "if" {
          let tempdroppin = CustomPinDrop(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(tempdroppin)
            self.tempdroppinlast = tempdroppin
            self.tempdropcircle = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(5))
            self.mapView.addOverlay(self.tempdropcircle)
        }
        else if testAnnType == "uif" {
            self.mapView.removeAnnotation(self.tempdroppinlast)
            self.mapView.removeOverlay(self.tempdropcircle)
        }
        else if testAnnType == "i" {
            self.postItem(screenCoordinate.latitude, long: screenCoordinate.longitude)
        }
        else if testAnnType == "ci" {
            self.mapView.removeAnnotation(self.drop1DropPin)
            self.mapView.removeOverlay(self.drop1Circle)
            self.mapView.removeAnnotation(self.drop2DropPin)
            self.mapView.removeOverlay(self.drop2Circle)
            self.mapView.removeAnnotation(self.drop3DropPin)
            self.mapView.removeOverlay(self.drop3Circle)
            self.mapView.removeAnnotation(self.drop4DropPin)
            self.mapView.removeOverlay(self.drop4Circle)
            self.mapView.removeAnnotation(self.drop5DropPin)
            self.mapView.removeOverlay(self.drop5Circle)
        }
        else if testAnnType == "o" {
            self.offensedroptemp = CustomPinBlueperson(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptemp)
        }
        else if testAnnType == "uo" {
            self.mapView.removeAnnotation(self.offensedroptemp)
        }
        else if testAnnType == "ox" {
            self.offensedroptempx = CustomPinBluepersonX(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptempx)
        }
        else if testAnnType == "uox" {
            self.mapView.removeAnnotation(self.offensedroptempx)
        }
        else if testAnnType == "of" {
            self.offensedroptempflag = CustomPinBluepersonflag(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.offensedroptempflag)
        }
        else if testAnnType == "uof" {
            self.mapView.removeAnnotation(self.offensedroptempflag)
        }
        else if testAnnType == "d" {
            self.defensedroptemp = CustomPinRedperson(coordinate: screenCoordinate, title: testAnnCaption)
            self.mapView.addAnnotation(self.defensedroptemp)
        }
        else if testAnnType == "ud" {
            self.mapView.removeAnnotation(self.defensedroptemp)
        }
        else if testAnnType == "hf" {
            self.mapView.removeAnnotation(self.pointDropPin)
            self.mapView?.removeOverlay(self.pointCircle)
        }
        else if testAnnType == "sf" {
            self.mapView.addAnnotation(self.pointDropPin)
            self.mapView?.addOverlay(self.pointCircle)
        }
        else if testAnnType == "af" {
            self.pointdroptemp.coordinate = screenCoordinate
            self.pointdroptemp.title = "Flag"
            self.mapView.addAnnotation(self.pointdroptemp)
            self.tempdropcircle2 = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(Int(testAnnCaption)!))
            self.mapView?.addOverlay(self.tempdropcircle2)
        }
        else if testAnnType == "uaf" {
            self.mapView.removeAnnotation(self.pointdroptemp)
            self.mapView?.removeOverlay(self.tempdropcircle2)
        }
        else if testAnnType == "gt" {
            gameTimerCount = Int(testAnnCaption)!
        }
        else if testAnnType == "tr" {
            self.circletemp = MKCircle(centerCoordinate: screenCoordinate, radius: CLLocationDistance(Int(testAnnCaption)!))
            self.mapView?.addOverlay(self.circletemp)
        }
        else if testAnnType == "utr" {
            self.mapView?.removeOverlay(self.circletemp)
        }
        else if testAnnType == "mm1" {
            self.postMineTag("asshat", inbox: "offense1Inbox")
        }
        else if testAnnType == "mm2" {
            self.postMineTag("asshat", inbox: "defense1Inbox")
        }

    }
    
    func hideTestView(hide: Bool) {
        if hide == true {
        self.thresholdLabel.hidden = true
        self.RSSILabel.hidden = true
        self.testButton.hidden = true
        self.testButton2Outlet.hidden = true
        }
        else if hide == false {
            self.thresholdLabel.hidden = false
            self.RSSILabel.hidden = false
            self.testButton.hidden = false
            self.testButton2Outlet.hidden = false
        }
    }
}



