//
//  StringExtention.swift
//  BeautyCamera
//
//  Created by Junsung Park on 2022/01/04.
//



import UIKit
import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized0(comment: String = "") -> String{
        return NSLocalizedString(self,value:self, comment: "")
    }
    func localized(with argument:CVarArg = [], comment:String = "") -> String{
        return String(format:self.localized0(comment:comment), argument)
    }
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    func findMentionText() -> [String] {
        
        
        var arr_hasStrings:[String] = []
        
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_가-힣ㄱ-ㅎ\\p{Arabic}\\p{N}]*)", options: [])
     
        let regEx0 = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
          
        let regexLink = try? NSRegularExpression(pattern: regEx0, options: [])
          
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
               for match in matches {
                   arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
               }
          
        }
        if let matches0 = regexLink?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
               for match in matches0 {
                   arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
               }
          
        }
    
        return arr_hasStrings
       
    }
    
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self)
        {
            return date
            
        } else {
            return nil
            
        }
    }
    func toDate2() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        
        let locale = Locale.current.identifier

        
      
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: locale)
        if let date = dateFormatter.date(from: self)
        {
            return date
            
        } else {
            return nil
            
        }
        
    }

    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    func capitalizingFirstLetter() -> String {
           return prefix(1).capitalized + dropFirst()
       }

       mutating func capitalizeFirstLetter() {
           self = self.capitalizingFirstLetter()
       }
    
    func isEqualToString(find: String) -> Bool {
           return String(format: self) == find
       }
    
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
           let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

           return ceil(boundingBox.height)
       }
}

extension Date {
    func toString() -> String
    {
        let locale = Locale.current.identifier

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd EEE"
    //    dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.locale = Locale(identifier: locale)
      
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
        
    }
    func toString2() -> String
    {
        let locale = Locale.current.identifier

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
        
    }
   
}

extension Int {
    var abbreviated : String {
        let numFormatter = NumberFormatter()

           typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
           let abbreviations:[Abbrevation] = [(0, 1, ""),
                                              (1000.0, 1000.0, "K"),
                                              (100_000.0, 1_000_000.0, "M"),
                                              (100_000_000.0, 1_000_000_000.0, "B")]
                                              // you can add more !
           let startValue = Double (abs(self))
           let abbreviation:Abbrevation = {
               var prevAbbreviation = abbreviations[0]
               for tmpAbbreviation in abbreviations {
                   if (startValue < tmpAbbreviation.threshold) {
                       break
                   }
                   prevAbbreviation = tmpAbbreviation
               }
               return prevAbbreviation
           } ()

         //  let value = Double(self) / abbreviation.divisor
        
        if(Double(self) >= 1000)
        {
            let ret0 =  Double(self) - Double( self  % 100)
            //let value = Double(self) / abbreviation.divisor
             let value = ret0 / abbreviation.divisor
               numFormatter.positiveSuffix = abbreviation.suffix
               numFormatter.negativeSuffix = abbreviation.suffix
               numFormatter.allowsFloats = true
               numFormatter.minimumIntegerDigits = 1
               numFormatter.minimumFractionDigits = 1
               numFormatter.maximumFractionDigits = 1

            return numFormatter.string(from: NSNumber (value:value))!
        }
        else
        {
           let value = Double(self) / abbreviation.divisor
               numFormatter.positiveSuffix = abbreviation.suffix
               numFormatter.negativeSuffix = abbreviation.suffix
               numFormatter.allowsFloats = true
               numFormatter.minimumIntegerDigits = 1
               numFormatter.minimumFractionDigits = 0
               numFormatter.maximumFractionDigits = 1

            return numFormatter.string(from: NSNumber (value:value))!
        }
        
       }
    var abbreviated2 : String {
       
        let numFormatter = NumberFormatter()

               typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
               let abbreviations:[Abbrevation] = [(0, 1, ""),
                                                  (100, 1000.0, "K"),
                                                  (100_000.0, 1_000_000.0, "M"),
                                                  (100_000_000.0, 1_000_000_000.0, "B")]
                                                  // you can add more !

               let startValue = Double (abs(self))
               let abbreviation:Abbrevation = {
                   var prevAbbreviation = abbreviations[0]
                   for tmpAbbreviation in abbreviations {
                       if (startValue < tmpAbbreviation.threshold) {
                           break
                       }
                       prevAbbreviation = tmpAbbreviation
                   }
                   return prevAbbreviation
               } ()

               let ret0 =  Double(self) - Double( self  % 100)
               //let value = Double(self) / abbreviation.divisor
                let value = ret0 / abbreviation.divisor
               numFormatter.positiveSuffix = abbreviation.suffix
               numFormatter.negativeSuffix = abbreviation.suffix
               numFormatter.allowsFloats = true
               numFormatter.minimumIntegerDigits = 1
               numFormatter.minimumFractionDigits = 1
               numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber (value:value))!
        /*
           typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
           let abbreviations:[Abbrevation] = [(0, 1, ""),
                                              (10.0, 1000.0, "K"),
                                              (100_000.0, 1_000_000.0, "M"),
                                              (100_000_000.0, 1_000_000_000.0, "B")]
                                              // you can add more !
           let startValue = Double (abs(self))
           let abbreviation:Abbrevation = {
               var prevAbbreviation = abbreviations[0]
               for tmpAbbreviation in abbreviations {
                   if (startValue < tmpAbbreviation.threshold) {
                       break
                   }
                   prevAbbreviation = tmpAbbreviation
               }
               return prevAbbreviation
           } ()

        //4.97
           let value = ( Double(self) / (abbreviation.divisor))
           let ret = String(format: "%.1f",floor(value))
           numFormatter.positiveSuffix = abbreviation.suffix
           numFormatter.negativeSuffix = abbreviation.suffix
           numFormatter.allowsFloats = true
           numFormatter.minimumIntegerDigits = 1
           numFormatter.minimumFractionDigits = 1
           numFormatter.maximumFractionDigits = 1

        return numFormatter.string(from: NSNumber (value:value))!
         */
        /*
        var num:Double = Double(self)
            let sign = ((num < 0) ? "-" : "" );

            num = fabs(num);

            if (num < 1000.0){
                return "\(sign)\(num)";
            }

            let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));

            let units:[String] = ["K","M","G","T","P","E"];

            let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;

        return "\(sign)\(roundedNum)\(units[exp-1])"
         */
       }
    
}
