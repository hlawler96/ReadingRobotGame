//
//  SettingsViewController.swift
//  Reading_Robot
//
//  Created by Derek Creason on 4/2/18.
//  Copyright © 2018 Derek Creason. All rights reserved.
//

import UIKit
import SQLite3

class SettingsViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    var fonts = ["ChalkboardSE-Bold", "HelveticaNeue-Bold", "KohinoorDevanagari-Medium", "MarkerFelt-Thin", "TimesNewRomanPS-BoldMT"]
    var fontNamesToDisplay = ["Chalkboard", "Helvetica", "Kohinoor", "MarkerFelt", "Times New Roman"]
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var fxSlider: UISlider!
    @IBOutlet weak var fontPicker: UIPickerView!
    @IBOutlet weak var stillModeSwitch: UISwitch!
    @IBOutlet weak var patternOnSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontPicker.delegate = self
        fontPicker.dataSource = self
        musicSlider.value = backgroundMusicPlayer.volume
        fontPicker.selectRow(fonts.index(of: font)!, inComponent: 0, animated: true)
        stillModeSwitch.isOn = stillMode
        patternOnSwitch.isOn = patternStaysOn
    }


    
    @IBAction func MusicVolumeChanged(_ sender: UISlider) {
        if sender == musicSlider {
            backgroundMusicPlayer.volume = musicSlider.value
            if sqlite3_exec(db, "UPDATE SettingsData SET musicVol =  \(musicSlider.value)" , nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error updating table: \(errmsg)")
            }
        }else if sender == fxSlider {
            // no FX currently so dont do anything, will update later
            if sqlite3_exec(db, "UPDATE SettingsData SET fxVol =  \(fxSlider.value)" , nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error updating table: \(errmsg)")
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let fontName = NSAttributedString(string: fontNamesToDisplay[row], attributes:  [NSAttributedStringKey.font:UIFont(name: fonts[row], size: 25)!])
        pickerLabel.attributedText = fontName
        pickerLabel.textAlignment = .center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        font = fonts[row]
        if sqlite3_exec(db, "UPDATE SettingsData SET font =  '" + font + "'"  , nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error updating table: \(errmsg)")
        }
    }

    @IBAction func settingSwitched(_ sender: UISwitch) {
        if sender == stillModeSwitch {
            // 1 is true and 0 is false
            stillMode = stillModeSwitch.isOn
            var i = 0
            if stillMode {
                i = 1
            }
            if sqlite3_exec(db, "UPDATE SettingsData SET stillMode =  \(i) " , nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error updating table: \(errmsg)")
            }
        }else {
            patternStaysOn = patternOnSwitch.isOn
            var i = 0
            if patternStaysOn {
                i = 1
            }
            if sqlite3_exec(db, "UPDATE SettingsData SET patternStays =  \(i) " , nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error updating table: \(errmsg)")
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true;
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
}
