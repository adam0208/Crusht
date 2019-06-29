//
//  EnterSchoolController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class EnterSchoolController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        schoolTF.text = myPickerData[row]        
    }
    
    let myPickerData = [String](arrayLiteral: "", "No College", "Abilene Cristian University", "Adelphi University", "Agnes Scott College", "Air Force Institute of Technology", "Alabama A&M University", "Alabama State University", "Alaska Pacific University", "Albertson College of Idaho", "Albion College", "Alderson-Broaddus College", "Alfred University", "Allegheny College", "Allentown College of Saint Francis de Sales", "Alma College", "Alverno College", "Ambassador University", "American Coastline University", "American Graduate School of International Managemen", "American International College", "American University", "Amherst College", "Andrews University", "Angelo State University", "Antioch College", "Antioch New England", "Antioch University-Los Angeles", "Antioch University-Seattle", "Appalachian State University", "Aquinas College", "Arizona State University", "Arizona State University East", "Arizona State University West", "Arizona Western College", "Arkansas State University", "Arkansas Tech University", "Armstrong State College", "Ashland University", "Assumption College", "Athens State College", "Auburn University", "Auburn University - Montgomery", "Augsburg College", "Augustana College (IL)", "Augustana College (SD)", "Aurora University", "Austin College", "Austin Peay State University", "Averett College", "Avila College", "Azusa Pacific University", "Babson College",    "Baldwin-Wallace College",
                                
                                
                                "Ball State University",
                                
                                
                                "Baker University",
                                
                                
                                "Baptist Bible College" ,
                                
                                
                                "Bard College" ,
                                
                                
                                "Barry University",
                                
                                
                                "Bastyr University",
                                
                                "Bates College",
                                
                                "Baylor College of Medicine",
                                
                                
                                "Baylor University" ,
                                
                                "Beaver College",
                                
                                "Belmont University",
                                
                                "Beloit College",
                                
                                "Bemidji State University",
                                
                                "Benedictine College",
                                
                                "Bennington College",
                                
                                "Bentley College",
                                
                                "Berea College",
                                
                                "Berklee College of Music",
                                
                                "Bethany College (CA)",
                                
                                "Bethany College (WV)",
                                
                                "Bethel College (KS)",
                                
                                "Bethel College and Seminary (MN)",
                                
                                "Biola University",
                                
                                "Birmingham-Southern College",
                                
                                "Black Hills State University",
                                
                                "Bloomsburg University of Pennsylvania",
                                
                                "Bluffton College",
                                
                                "Bob Jones University (BJU)",
                                
                                "Boise State University",
                                
                                "Boston College",
                                
                                "Boston Graduate School of Psychoanalysis",
                                
                                "Boston University",
                                
                                "Bowdoin College",
                                
                                "Bowie State University",
                                
                                "Bowling Green State University",
                                
                                "Bradley University",
                                
                                "Brandeis University",
                                
                                "Brenau University",
                                
                                "Briar Cliff College",
                                
                                "Bridgewater College",
                                
                                "Brigham Young University",
                                
                                "Brigham Young University Hawaii",
                                
                                "Brown University",
                                
                                "Bryant College",
                                
                                "Bryn Mawr College",
                                
                                "Bucknell University",
                                
                                "Buena Vista University",
                                
                                "Butler University",
                                
                                "California Coast University",
                                
                                "California Institute of Technology",
                                
                                "California Lutheran University",
                                
                                "California Maritime Academy",
                                
                                "California National University",
                                
                                "California Pacific University",
                                
                                "California Polytechnic State University, San Luis Obispo",
                                
                                "California School of Professional Psychology",
                                
                                "California State Polytechnic University, Pomona",
                                
                                "California State University System",
                                
                                "California State University, Bakersfield",
                                
                                "California State University, Chico",
                                
                                "California State University, Dominguez Hills",
                                
                                "California State University, Fresno",
                                
                                "California State University, Fullerton",
                                
                                "California State University, Hayward",
                                
                                "California State University, Long Beach",
                                
                                "California State University, Los Angeles",
                                "California State University, Monterey Bay",
                                
                                "California State University, Northridge",
                                
                                "California State University, Sacramento",
                                
                                "California State University, San Bernardino",
                                
                                "California State University, San Jose",
                                
                                "California State University, San Marcos",
                                
                                "California State University, Sacramento",
                                
                                "California State University, Stanislaus",
                                
                                "California University of Pennsylvania",
                                
                                "Calvin College",
                                
                                "Campbell University",
                                
                                "Campbellsville College",
                                
                                "Cameron University",
                                "Canisius College",
                                
                                "Carleton College",
                                
                                "Carlow College",
                                
                                "Carnegie Mellon University",
                                
                                "Carroll College (MT)",
                                
                                "Carroll College (WI)",
                                
                                "Carson-Newman College",
                                
                                "Carthage College",
                                
                                "Case Western Reserve University",
                                
                                "Castleton State University",
                                
                                "The Catholic University of America",
                                
                                "Cedarville College",
                                
                                "Centenary College of Louisiana",
                                
                                "Central College",
                                
                                "Central Connecticut State University",
                                
                                "Central Methodist College",
                                
                                "Central Michigan University",
                                
                                "Central Missouri State University",
                                
                                "Central Washington University",
                                
                                "Centre College",
                                
                                "Chadron State College",
                                
                                "Champlain College",
                                
                                "Chapman University",
                                
                                "Chatham College",
                                
                                "Chesapeake College",
                                
                                "Cheyney University",
                                
                                "The Chicago School of Professional Psychology",
                                
                                "Christian Brothers University",
                                
                                "Christian Theological Seminary",
                                
                                "Christopher Newport University",
                                
                                "The Citadel",
                                
                                "City University",
                                
                                "City University of New York",
                                
                                "Claremont Graduate School",
                                
                                "Claremont McKenna College",
                                
                                "Clarion University of Pennsylvania",
                                
                                "Clark University",
                                
                                "Clarke College",
                                
                                "Clarkson University",
                                
                                "Clayton State College",
                                
                                "Clemson University",
                                
                                "Cleveland State University",
                                
                                "Clinch Valley College",
                                
                                "Coastal Carolina University",
                                
                                "Coe College",
                                
                                "Coker College",
                                
                                "Colby College",
                                
                                "Colgate University",
                                
                                "College of the Atlantic",
                                
                                "College of Charleston",
                                
                                "College of Eastern Utah",
                                
                                "College of the Holy Cross",
                                
                                "College of Saint Benedict",
                                
                                "College of Saint Catherine",
                                
                                "College of St. Francis",
                                
                                "College of Saint Rose",
                                
                                "College of St. Scholastica",
                                
                                "College of William and Mary",
                                
                                "The College of Wooster",
                                
                                "Colorado Christian University",
                                
                                "Colorado College",
                                
                                "Colorado School of Mines",
                                
                                "Colorado State University",
                                
                                "Columbia College Chicago",
                                
                                "Columbia Southern University",
                                
                                "Columbia Union College",
                                
                                "Columbia University",
                                
                                "Concordia College-Ann Arbor",
                                
                                "Concordia College-Moorhead",
                                
                                "Concordia College-St. Paul",
                                
                                "Concordia College-Seward",
                                
                                "Concordia University River Forest, Illinois",
                                
                                "Connecticut College",
                                
                                "The Cooper Union for the Advancement of Science and Art",
                                
                                "Coppin State College",
                                
                                "Cornell College",
                                
                                "Cornell University",
                                
                                "Cornerstone College",
                                
                                "Creighton University",
                                
                                "Curry College",
                                
                                "Daemen College",
                                
                                "Dakota State University",
                                
                                "Dakota Wesleyan University",
                                
                                "Dallas Baptist University",
                                
                                "Dana College",
                                
                                "Daniel Webster College",
                                
                                "Dartmouth College",
                                
                                "Davenport College Detroit College of Business",
                                
                                "Davidson College",
                                
                                "Davis & Elkins College",
                                
                                "Delaware State University",
                                
                                "Delta State University",
                                
                                "Denison University",
                                
                                "DePaul University",
                                
                                "DePauw University",
                                
                                "DeVry Institute of Technology",
                                
                                "DeVry Institute of Technology-Dallas",
                                
                                "DeVry Institute of Technology-Phoenix",
                                
                                "Dickinson College",
                                
                                "Dickinson State University",
                                
                                "Dillard University",
                                
                                "Dominican College",
                                
                                "Dordt College",
                                
                                "Dowling College",
                                
                                "Drake University",
                                
                                "Drew University",
                                
                                "Drexel University",
                                
                                "Drury College",
                                
                                "Duke University",
                                
                                "Duquesne University",
                                
                                "Earlham College",
                                
                                "East Carolina University",
                                
                                "East Central University",
                                
                                "East Stroudsburg State University of Pennsylvania",
                                
                                "East Tennessee State University",
                                
                                "East Texas State University",
                                
                                "Eastern Connecticut State University",
                                
                                "Eastern Illinois University",
                                
                                "Eastern Kentucky University",
                                
                                "Eastern Mennonite University",
                                
                                "Eastern Michigan University",
                                
                                "Eastern Nazarene College",
                                
                                "Eastern New Mexico University",
                                
                                "Eastern Oregon State College",
                                
                                "Eastern Washington University",
                                
                                "Edgewood College",
                                
                                "Edinboro University of Pennsylvania",
                                
                                "Elizabeth City State University",
                                
                                "Elizabethtown College",
                                
                                "Elmhurst College",
                                
                                "Elon College",
                                
                                "Embry-Riddle Aeronautical University, Arizona",
                                
                                "Embry-Riddle Aeronautical University, Florida",
                                
                                "Emerson College",
                                
                                "Emmanuel College",
                                
                                "Emmaus Bible College",
                                
                                "Emporia State University",
                                
                                "Emory & Henry College",
                                
                                "Emory University",
                                
                                "Evergreen State College",
                                
                                "Fairfield University",
                                
                                
                                "Fairleigh Dickinson University",
                                
                                "Fairmont State College",
                                
                                "Fayetteville State University",
                                
                                "Ferris State University",
                                
                                "Fielding Institute",
                                
                                "Fisk University",
                                
                                "Fitchburg State College",
                                
                                "Florida Agricultural and Mechanical University",
                                
                                "Florida Atlantic University",
                                
                                "Florida Gulf Coast University",
                                
                                "Florida Institute of Technology",
                                
                                "Florida International University",
                                
                                "Florida State University",
                                
                                "Fontbonne College",
                                
                                "Fordham University",
                                
                                "Fort Hays State University",
                                
                                "Fort Lewis College",
                                
                                "Franciscan University",
                                
                                "Franklin and Marshall College",
                                
                                "Franklin Pierce Law Center",
                                
                                "Franklin University",
                                
                                "Fresno Pacific University",
                                
                                "Friends University",
                                
                                "Frostburg State University",
                                
                                "Fuller Theological Seminary",
                                
                                "Furman University",
                                
                                "Gallaudet University",
                                
                                "Gannon University",
                                
                                "Geneva College",
                                
                                "George Fox College",
                                
                                "George Mason University",
                                
                                "George Washington University",
                                
                                "Georgetown University",
                                
                                "Georgia College",
                                
                                "Georgia Institute of Technology",
                                
                                "Georgia Southern University",
                                
                                "Georgia Southwestern College",
                                
                                "Georgia State University",
                                
                                "Georgian Court College",
                                
                                "Gettysburg College",
                                
                                "GMI Engineering and Management Institute",
                                
                                "Golden Gate University",
                                
                                "Goldey-Beacom College",
                                
                                "Gonzaga University",
                                
                                "Goshen College",
                                
                                "Goucher College",
                                
                                "Governors State University",
                                
                                "Grace College",
                                
                                "Graceland College",
                                
                                "Grand Valley State University",
                                
                                "Greenleaf University",
                                
                                "Grinnell College",
                                
                                "Guilford College",
                                
                                "Gustavus Adolphus College",
                                
                                "Gutenberg College",
                                
                                "Hamilton College",
                                
                                "Hamline University",
                                
                                "Hampden-Sydney College",
                                
                                "Hampshire College",
                                
                                "Hampton University",
                                
                                "Hanover College",
                                
                                "Harding University",
                                
                                "Hartwick College",
                                
                                "Harvard University",
                                
                                "Harvey Mudd College",
                                
                                "Haskell Indian Nations University",
                                
                                "Hastings College",
                                
                                "Haverford College in Pennsylvania",
                                
                                "Hawaii Pacific University",
                                
                                "Heidelberg College",
                                
                                "Hendrix College",
                                
                                "Hesston College",
                                
                                "High Point University",
                                
                                "Hillsdale College",
                                
                                "Hiram College",
                                
                                "Hobart and William Smith Colleges",
                                
                                "Hofstra University",
                                
                                "Hollins College",
                                
                                "Holy Cross College",
                                
                                "Hood College",
                                
                                "Hope College",
                                
                                "Howard University",
                                
                                "Humboldt State University",
                                
                                "Hunter College",
                                
                                "Huntingdon College",
                                
                                "Huntington College",
                                
                                "ICI University",
                                
                                "Idaho State University",
                                
                                "Illinois Benedictine College",
                                
                                "Illinois Institute of Technology",
                                
                                "Illinois State University",
                                
                                "Incarnate Word College",
                                
                                "Indiana Institute of Technology",
                                
                                "Indiana State University",
                                
                                "Indiana University System",
                                
                                "Indiana University/Purdue University at Columbus",
                                
                                "Indiana University/Purdue University at Fort Wayne",
                                
                                "Indiana University/Purdue University at Indianapolis",
                                
                                "Indiana University at Bloomington",
                                
                                "Indiana University at South Bend",
                                
                                "Indiana University of Pennsylvania",
                                
                                "Indiana University Southeast at New Albany",
                                
                                "Indiana Wesleyan University, Marion",
                                
                                "Inter American University of Puerto Rico Metropolitan Campus",
                                
                                "Iona College",
                                
                                "Iowa State University",
                                
                                "Ithaca College",
                                
                                "Jackson State University",
                                
                                "Jacksonville University",
                                
                                "Jacksonville State University",
                                
                                "James Madison University",
                                
                                "Jamestown College",
                                
                                "The Jewish Theological Seminary",
                                
                                "John Brown University",
                                
                                "John F. Kennedy University",
                                
                                "Johns Hopkins University",
                                
                                "Johnson Bible College",
                                
                                "Johnson C. Smith University",
                                
                                "Johnson &amp; Wales University",
                                
                                "Johnson &amp; Wales University-Charleston",
                                
                                "Jones College",
                                
                                "Judson College",
                                
                                "Juniata College",
                                
                                "Kalamazoo College",
                                
                                "Kansas State University",
                                
                                "Kansas Wesleyan University",
                                
                                "Kean College",
                                
                                "Keene State College",
                                
                                "Kent State University",
                                
                                "Kenyon College",
                                
                                "King's College",
                                
                                "Knox College",
                                
                                "Kutztown University of Pennsylvania",
                                
                                "La Sierra University",
                                
                                "LaGrange College",
                                
                                "Lafayette College",
                                
                                "Lake Forest College",
                                
                                "Lake Superior State University",
                                
                                "Lamar University",
                                
                                "Langston University",
                                
                                "LaSalle University",
                                
                                "Lawrence University",
                                
                                "Lawrence Technological University",
                                "Lebanon Valley College",
                                
                                "Lehigh Univervsity",
                                
                                "Le Moyne College",
                                
                                "Lenoir-Rhyne College",
                                
                                "LeTourneau University",
                                
                                "Lewis & Clark College",
                                
                                "Lewis-Clark State College",
                                
                                "Lewis University",
                                
                                "Liberty University",
                                
                                "Lincoln University",
                                
                                "Linfield College",
                                
                                "Lock Haven University of Pennsylvania",
                                
                                "Loma Linda University",
                                
                                "Long Island University"
        ,
                                "Longwood College"
        ,
                                "Loras College",
                                
                                "Louisiana College",
                                
                                "Louisiana State University",
                                
                                "Louisiana State University at Alexandria",
                                
                                "Louisiana State University at Shreveport",
                                
                                "Louisiana Tech University",
                                
                                "Loyola College",
                                
                                "Loyola Marymount University",
                                
                                "Loyola University Chicago",
                                
                                "Luther College",
                                
                                "Luther Seminary",
                                
                                "Lycoming College",
                                
                                "Lynchburg College",
                                
                                "Lyndon State College",
                                
                                "Lyon College",
                                
                                "Macalester College",
                                
                                "Maharishi University of Management",
                                
                                "Maine Maritime Academy",
                                
                                "Malone College",
                                
                                "Manhattan College",
                                
                                "Mankato State University",
                                
                                "Mansfield University of Pennsylvania",
                                
                                "Marietta College",
                                
                                "Marist College",
                                
                                "Marlboro College",
                                
                                "Marquette University",
                                
                                "Marshall University",
                                
                                "Mary Baldwin College",
                                
                                "Marymount College",
                                
                                "Marymount University",
                                
                                "Mary Washington College",
                                
                                "Massachusetts Institute of Technology",
                                
                                "McMurry University",
                                
                                "McNeese State University",
                                
                                "Medical College of Georgia",
                                
                                "Medical College of Wisconsin",
                                
                                "Mercer University",
                                
                                "Mercyhurst College",
                                
                                "Meredith College",
                                
                                "Messiah College",
                                
                                "Metropolitan State College of Denver",
                                
                                "Metropolitan State University",
                                
                                "Miami Christian University",
                                
                                "Miami University of Ohio",
                                
                                "Michigan State University",
                                
                                "Michigan Technological University",
                                
                                "Mid-America Nazarene College",
                                
                                "Middlebury College",
                                
                                "Middle Georgia College",
                                
                                "Middle Tennessee State University",
                                
                                "Midwestern State University",
                                
                                "Millersville University of Pennsylvania",
                                
                                "Milligan College",
                                
                                "Millikin University",
                                
                                "Millsaps College",
                                
                                "Milwaukee School of Engineering",
                                
                                "Minot State University",
                                
                                "Minneapolis College of Art and Design",
                                
                                "Mississippi College",
                                
                                "Mississippi State University",
                                
                                "Mississippi University for Women",
                                
                                "Missouri Southern State College",
                                
                                "Missouri Western State College",
                                
                                "Molloy College",
                                
                                "Monmouth College",
                                
                                "Monmouth University",
                                
                                "Montana State University-Billings",
                                
                                "Montana State University-Bozeman",
                                
                                "Montana State University-Northern",
                                
                                "Montana Tech",
                                
                                "Montclair State University",
                                
                                "Montreat College",
                                
                                "Moravian College",
                                
                                "Moorhead State University",
                                
                                "Morehouse College",
                                
                                "Morgan State University",
                                
                                "Mount Senario College",
                                
                                "Mount Holyoke College",
                                
                                "Mount Saint Joseph College",
                                
                                "Mount Saint Mary College",
                                
                                "Mount Union College",
                                
                                "Murray State University",
                                
                                "Muskingum College",
                                
                                "National Defense University",
                                
                                "National-Louis University",
                                
                                "National Technological University",
                                
                                "National University",
                                
                                "Naval Postgraduate School",
                                
                                "Nazareth College",
                                
                                "Newberry College",
                                
                                "New England Institute of Technology",
                                
                                "New College of California",
                                
                                "New Hampshire College",
                                
                                "New Jersey Institute of Technology",
                                
                                "New Mexico Highlands University",
                                
                                "New Mexico Institute of Mining &amp; Technology",
                                
                                "New Mexico State University",
                                
                                "New York Institute of Technology",
                                
                                "New York University",
                                
                                "Niagara University",
                                
                                "Nicholls State University",
                                
                                "Norfolk State University",
                                
                                "North Adams State College",
                                
                                "North Carolina Central University",
                                
                                "North Carolina A&amp;T State University",
                                
                                "North Carolina State University",
                                
                                "North Carolina Wesleyan College",
                                
                                "North Central Bible College",
                                
                                "North Dakota State University",
                                
                                "Northland College",
                                
                                "North Park College and Theological Seminary",
                                
                                "Northeastern Illinois University",
                                
                                "Northeastern Louisiana University",
                                
                                "Northeastern State University",
                                
                                "Northeastern University",
                                
                                "Northern Arizona University",
                                
                                "Northern Illinois University",
                                
                                "Northern Kentucky University",
                                
                                "Northern Michigan University",
                                
                                "Northern State University",
                                
                                "Northwest Missouri State University",
                                
                                "Northwest Nazarene College",
                                
                                "Northwestern College of Iowa",
                                
                                "Northwestern State University",
                                
                                "Northwestern University",
                                
                                "Norwich University",
                                
                                "Nova Southeastern University",
                                
                                "Oakland University",
                                
                                "Oberlin College",
                                
                                "Occidental College",
                                
                                "Ohio Dominican College",
                                
                                "Ohio Northern University",
                                
                                "Ohio State University, Columbus",
                                
                                "Ohio State University, Marion",
                                
                                "Ohio Wesleyan University",
                                
                                "Ohio University, Athens",
                                
                                "Oklahoma Baptist University",
                                
                                "Oklahoma City University",
                                
                                "Oklahoma State University",
                                
                                "Old Dominion University",
                                
                                "Olivet Nazarene University",
                                
                                "Oral Roberts University",
                                
                                "Oregon Graduate Institute of Science and Technology",
                                
                                "Oregon Health Sciences University",
                                
                                "Oregon Institute of Technology",
                                
                                "Oregon State University",
                                
                                "Otterbein College",
                                
                                "Our Lady of the Lake University",
                                
                                "Pace University",
                                
                                "Pacific Lutheran University",
                                
                                "Pacific Union College",
                                
                                "Pacific University",
                                
                                "Pacific Western University",
                                
                                "Palm Beach Atlantic College",
                                
                                "Peace College",
                                
                                "Pembroke State University",
                                
                                "Pennsylvania State System of Higher Education",
                                
                                "Pennsylvania State University",
                                
                                "Pennsylvania State University-Schuylkill Campus",
                                
                                "Pensacola Christian College",
                                
                                "Pepperdine University",
                                
                                "Peru State College",
                                
                                "Philadelphia College of Textiles and Science",
                                
                                "Phillips University",
                                
                                "Pittsburg State University",
                                
                                "Pitzer College",
                                
                                "Platt College",
                                
                                "Plymouth State College",
                                
                                "Point Loma Nazarene College",
                                
                                "Polytechnic University of New York",
                                
                                "Polytechnic University of Puerto Rico",
                                
                                "Pomona College",
                                
                                "Portland State University",
                                
                                "Prairie View A&amp;M University",
                                
                                "Pratt Institute",
                                
                                "Prescott College",
                                
                                "Princeton University",
                                
                                "Presbyterian College",
                                
                                "Providence College",
                                
                                "Purdue University",
                                
                                "Purdue University Calumet",
                                
                                "Purdue University North Central",
                                
                                "Quincy University",
                                
                                "Quinnipiac College",
                                
                                "Radford University",
                                
                                "Ramapo College",
                                
                                "Randolph-Macon College",
                                
                                "Randolph-Macon Woman's College",
                                
                                "Reed College",
                                
                                "Regent University",
                                
                                "Regis University",
                                
                                "Rensselaer Polytechnic Institute",
                                
                                "Rhode Island College",
                                
                                "Rhodes College",
                                
                                "Rice University",
                                
                                "Richard Stockton College of New Jersey",
                                
                                "Rider University",
                                
                                "Ripon College",
                                
                                "Rivier College",
                                
                                "Roanoke College",
                                
                                "Rochester Institute of Technology",
                                
                                "The Rockefeller University",
                                
                                "Rockford College",
                                
                                "Rockhurst College",
                                
                                "Rocky Mountain College",
                                
                                "Roger Williams University",
                                
                                "Rollins College",
                                
                                "Rosary College",
                                
                                "Rose-Hulman Institute of Technology",
                                
                                "Rowan College",
                                
                                "Rutgers University",
                                
                                "Rutgers University, Camden",
                                
                                "Rutgers University, Newark",
                                
                                "The Sage Colleges",
                                
                                "Sacred Heart University (CT)",
                                
                                "Sacred Heart University (PR)",
                                
                                "Saginaw Valley State University",
                                
                                "St. Ambrose University" ,
                                
                                
                                "St. Andrews Presbyterian College",
                                
                                "Saint Anselm College",
                                
                                "St. Bonaventure University",
                                
                                "Saint Cloud State University",
                                
                                "Saint Edward's University",
                                
                                "Saint Francis College",
                                
                                "St. John's College-Annapolis",
                                
                                "St. John's College-Santa Fe",
                                
                                "Saint John's University",
                                
                                "Saint John's University",
                                
                                "St. Joseph College (CT)",
                                
                                "Saint Joseph's College (IN)",
                                
                                "St. Joseph's College (ME)",
                                
                                "Saint Joseph's University",
                                
                                "St. Lawrence University",
                                
                                "St. Louis College of Pharmacy",
                                
                                "Saint Louis University",
                                
                                "St. Martin's College",
                                
                                "Saint Mary College",
                                
                                "Saint Mary's College (IN)",
                                
                                "Saint Mary's College of California",
                                
                                "Saint Mary's University of Minnesota",
                                
                                "Saint Michael's College",
                                
                                "Saint Olaf College",
                                
                                "St. Thomas University (FL)",
                                
                                "Saint Vincent College",
                                
                                "Saint Xavier University",
                                
                                "Salisbury State University",
                                
                                "Salish Kootenai College",
                                
                                "Sam Houston State University",
                                
                                "Samford University",
                                
                                "San Diego State University",
                                
                                "San Francisco State University",
                                
                                "San Jose State University",
                                
                                "Santa Clara University",
                                
                                "Sarah Lawrence College",
                                
                                "School of the Art Institute of Chicago",
                                
                                "Seattle Pacific University",
                                
                                "Seattle University",
                                
                                "Seton Hall University",
                                
                                "Sewanee, University of the South",
                                
                                
                                "Shawnee State University",
                                
                                "Shenandoah University",
                                
                                "Shippensburg University of Pennsylvania",
                                
                                "Shorter College",
                                
                                "Simmons College",
                                
                                "Simon's Rock College",
                                
                                "Simpson College",
                                
                                "Skidmore College",
                                
                                "Slippery Rock University of Pennsylvania",
                                
                                "Smith College",
                                
                                "Sonoma State University",
                                
                                "South Dakota School of Mines and Technology",
                                
                                "South Dakota State University",
                                
                                "Southeast Missouri State University",
                                
                                "Southeastern Louisiana University",
                                
                                "Southern College",
                                
                                "Southern College of Technology",
                                
                                "Southern Connecticut State University",
                                
                                "Southern Illinois University",
                                
                                "Southern Illinois University-Carbondale",
                                
                                "Southern Illinois University-Edwardsville",
                                
                                "Southern Methodist University",
                                
                                "Southern Nazarene University",
                                
                                "Southern Oregon State College",
                                
                                "Southern University",
                                
                                "Southern Utah University",
                                
                                "Southampton College",
                                
                                "South Texas College of Law",
                                
                                "Southwest Baptist University",
                                
                                "Southwest Missouri State University",
                                
                                "Southwest State University",
                                
                                "Southwest Texas State University",
                                
                                "Southwestern Adventist College",
                                
                                "Southwestern University",
                                
                                "Spelman College",
                                
                                "Spring Arbor College",
                                
                                "Spring Hill College",
                                
                                "Stanford University",
                                
                                "State University of New York System",
                                
                                "State University of New York at Albany",
                                
                                "State University of New York College of Technology at Alfred",
                                
                                "State University of New York at Binghamton",
                                
                                "State University of New York College at Brockport",
                                
                                "State University of New York at Buffalo",
                                
                                "State University of New York College at Buffalo (Buffalo State College)",
                                
                                "State University of New York College of Agriculture and Technology at Cobleskill",
                                
                                "State University of New York College at Cortland",
                                
                                "State University of New York College of Environmental Science and Forestry",
                                
                                "State University of New York at Farmingdale",
                                
                                "State University of New York at Fredonia",
                                
                                "State University of New York College at Geneseo",
                                
                                "State University of New York College at New Paltz",
                                
                                "State University of New York College at Oneonta",
                                
                                "State University of New York at Oswego",
                                
                                "State University of New York at Plattsburgh",
                                
                                "State University of New York College at Potsdam",
                                
                                "State University of New York at Stony Brook",
                                
                                "State University of New York Institute of Technology at Utica/Rome",
                                
                                "Stephen F. Austin State University",
                                
                                "Stephens College",
                                
                                "Stetson University",
                                
                                "Stevens Institute of Technology",
                                
                                "Strayer College",
                                
                                "Suffolk University",
                                
                                "Sul Ross State University",
                                
                                "Summit University of Louisiana",
                                
                                "Susquehanna University",
                                
                                "Swarthmore College",
                                
                                "Sweet Briar College",
                                
                                "Syracuse University",
                                
                                "Tabor College",
                                
                                "Tarleton State University",
                                
                                "Taylor University",
                                
                                "Teachers College, Columbia University",
                                
                                "Teikyo Marycrest University",
                                
                                "Temple University",
                                
                                "Tennessee State University",
                                
                                "Tennessee Technological University",
                                
                                "Texas A&M International University",
                                
                                "Texas A&amp;M University-College Station",
                                
                                "Texas A&amp;M University-Corpus Christi",
                                
                                "Texas A&M University-Kingsville",
                                
                                "Texas Christian University",
                                
                                "Texas Southern University",
                                
                                "Texas Tech University",
                                
                                "Texas Tech University-Health Sciences Center",
                                
                                "Texas Woman's University",
                                
                                "Thomas College",
                                
                                "Thomas Edison State College",
                                
                                "Thomas Jefferson University",
                                
                                "Thomas More College",
                                
                                "Towson State University",
                                
                                "Transylvania University",
                                
                                "Trenton State College",
                                
                                "Trinity College (CT)",
                                
                                "Trinity College",
                                
                                "Trinity University",
                                
                                "Troy State University",
                                
                                "Truman State University",
                                
                                "Tucson University",
                                
                                "Tufts University",
                                
                                "Tulane University",
                                
                                "Tuskegee University",
                                
                                "Union College",
                                
                                "The Union Institute",
                                
                                "Union University",
                                
                                "United States Air Force Academy",
                                
                                "United States International University",
                                
                                "United States Merchant Marine Academy",
                                
                                "United States Military Academy",
                                
                                "United States Naval Academy",
                                
                                "The Uniformed Services University of the Health Sciences",
                                
                                "Ursinus College",
                                
                                "Ursuline College",
                                
                                "University of Akron",
                                
                                "University of Alabama at Birmingham",
                                
                                "University of Alabama at Huntsville",
                                
                                "University of Alabama at Tuscaloosa",
                                
                                "University of Alaska",
                                
                                "University of Alaska-Anchorage",
                                
                                "University of Alaska-Fairbanks",
                                
                                "University of Alaska-Southeast",
                                
                                "University of Arizona",
                                
                                "University of Arkansas",
                                
                                "University of Arkansas - Little Rock",
                                
                                "University of Arkansas for Medical Sciences",
                                
                                "University of Arkansas - Monticello",
                                
                                "University of Baltimore",
                                
                                "University of Bridgeport",
                                
                                "University of California, Berkeley",
                                
                                "University of California, Davis",
                                
                                "University of California, Irvine",
                                
                                "University of California, Los Angeles",
                                
                                "University of California, Riverside",
                                
                                "University of California, San Diego",
                                
                                "University of California, San Francisco",
                                
                                "University of California, Santa Barbara",
                                
                                "University of California, Santa Cruz",
                                
                                "University of Central Arkansas",
                                
                                "University of Central Florida",
                                
                                "University of Central Texas",
                                
                                "University of Charleston",
                                
                                "University of Chicago",
                                
                                "University of Cincinnati",
                                
                                "University of Colorado at Boulder",
                                
                                "University of Colorado at Colorado Springs",
                                
                                "University of Colorado at Denver",
                                
                                "University of Colorado Health Sciences Center",
                                
                                "University of Connecticut",
                                
                                "University of Dallas",
                                
                                "University of Dayton",
                                
                                "University of Delaware",
                                
                                "University of Denver",
                                
                                "University of the District of Columbia",
                                
                                "University of Detroit Mercy",
                                
                                "University of Dubuque",
                                
                                "University of Evansville",
                                
                                "University of Florida",
                                
                                "University of Georgia",
                                
                                "University of Great Falls",
                                
                                "University of Guam",
                                
                                "University of Hartford",
                                
                                "University of Hawaii at Hilo Physics and Astronomy",
                                
                                "University of Hawaii at Manoa",
                                
                                "University of Houston",
                                
                                "University of Idaho",
                                
                                "University of Illinois at Chicago",
                                
                                "University of Illinois at Springfield",
                                
                                "University of Ilinois at Urbana-Champaign",
                                
                                "University of Indianapolis",
                                
                                "University of Iowa",
                                
                                "University of Kansas",
                                
                                "University of Kansas School of Medicine",
                                
                                "University of Kentucky",
                                
                                "University of La Verne",
                                
                                "University of Louisville",
                                
                                "University of Maine System",
                                
                                "University of Maine",
                                
                                "University of Maine at Farmington",
                                
                                "University of Maine at Fort Kent",
                                
                                "University of Maine at Machias",
                                
                                "University of Maine at Presque Island",
                                
                                "University of Maryland at Baltimore",
                                
                                "University of Maryland at Baltimore County",
                                
                                "University of Maryland at College Park",
                                
                                "University of Maryland - University College",
                                
                                "University of Massachusetts System",
                                
                                "University of Massachusetts at Amherst",
                                
                                "University of Massachusetts at Dartmouth",
                                
                                "University of Massachusetts at Lowell",
                                
                                "University of Memphis",
                                
                                "University of Miami",
                                
                                "University of Michigan-Ann Arbor",
                                
                                "University of Michigan-Dearborn",
                                
                                "University of Minnesota",
                                
                                "University of Minnesota-Crookston",
                                
                                "University of Minnesota-Duluth",
                                
                                "University of Minnesota-Morris",
                                
                                "University of Minnesota-Twin Cities",
                                
                                "University of Mississippi",
                                
                                "University of Mississippi Medical Center",
                                
                                "University of Missouri System",
                                
                                "University of Missouri-Columbia",
                                
                                "University of Missouri-Kansas City",
                                
                                "University of Missouri-Rolla",
                                
                                "University of Missouri-Saint Louis",
                                
                                "University of Montana",
                                
                                "University of Nebraska, Kearney",
                                
                                "University of Nebraska, Lincoln",
                                
                                "University of Nebraska, Omaha",
                                
                                "University of Nevada, Las Vegas",
                                
                                "University of Nevada, Reno",
                                
                                "University of New England",
                                
                                "University of New Hampshire, Durham",
                                
                                "University of New Haven",
                                
                                "University of New Mexico",
                                
                                "University of New Orleans",
                                
                                "University of North Carolina at Asheville",
                                
                                "University of North Carolina at Chapel Hill",
                                
                                "University of North Carolina at Charlotte",
                                
                                "University of North Carolina at Greensboro",
                                
                                "University of North Carolina System",
                                
                                "University of North Carolina at Wilmington",
                                
                                "University of North Dakota",
                                
                                "University of North Florida",
                                
                                "University of North Texas",
                                
                                "University of North Texas Health Science Center",
                                
                                "University of Northern Colorado",
                                
                                "University of Northern Iowa",
                                
                                "University of Notre Dame",
                                
                                "University of Oklahoma",
                                
                                "University of Oregon",
                                
                                "University of the Ozarks",
                                
                                "University of the Pacific",
                                
                                "University of Pennsylvania",
                                
                                "University of Phoenix",
                                
                                "University of Pittsburgh",
                                
                                "University of Pittsburgh at Johnstown",
                                
                                "University of Portland",
                                
                                "University of Puerto Rico",
                                
                                "University of Puget Sound",
                                
                                "University of Redlands",
                                
                                "University of Rhode Island",
                                
                                "University of Richmond",
                                
                                "University of Rochester",
                                
                                "University of San Diego",
                                
                                "University of San Francisco",
                                
                                "University of Sarasota",
                                
                                "University of Science &amp; Arts of Oklahoma",
                                
                                "University of Scranton",
                                
                                "University of Sioux Falls",
                                
                                "University of Southern California",
                                
                                "University of South Carolina",
                                
                                "University of South Carolina - Aiken",
                                
                                "University of South Dakota",
                                
                                "University of South Florida",
                                
                                "University of Southern Maine",
                                
                                "University of Southern Mississippi",
                                
                                "University of Southwestern Louisiana",
                                
                                "University of Saint Thomas",
                                
                                "University of Saint Thomas (MN)",
                                
                                "University of South Alabama",
                                
                                "University of Southern Colorado",
                                
                                "University of Southern Indiana",
                                
                                "University of Tampa",
                                
                                "University of Tennessee, Knoxville",
                                
                                "University of Tennessee, Martin",
                                
                                "University of Texas System",
                                
                                "University of Texas at Arlington",
                                
                                "University of Texas at Austin",
                                
                                "University of Texas at Brownsville",
                                
                                "University of Texas at Dallas",
                                
                                "University of Texas at El Paso",
                                
                                "University of Texas-Pan American",
                                
                                "University of Texas at San Antonio",
                                
                                "University of Texas Health Science Center at Houston",
                                
                                "University of Texas Health Science Center at San Antonio",
                                
                                "University of Texas at Tyler",
                                
                                "University of Texas Health Center at Tyler",
                                
                                "University of Texas M.D. Anderson Cancer Center",
                                
                                "University of Texas Medical Branch",
                                
                                "University of Texas Southwestern Medical Center at Dallas",
                                
                                "University of Toledo",
                                
                                "University of Tulsa",
                                
                                "University of Utah",
                                
                                "University of Vermont",
                                
                                "University of the Virgin Islands",
                                
                                "University of Virginia, Charlottesville",
                                
                                "University of Washington",
                                
                                "University of West Alabama",
                                
                                "University of West Florida",
                                
                                "University of Wisconsin System",
                                
                                "University of Wisconsin-Eau Claire",
                                
                                "University of Wisconsin-Green Bay",
                                
                                "University of Wisconsin-LaCrosse",
                                
                                "University of Wisconsin-Madison",
                                
                                "University of Wisconsin-Milwaukee",
                                
                                "University of Wisconsin-Oshkosh",
                                
                                "University of Wisconsin-Parkside",
                                
                                "University of Wisconsin-Platteville",
                                
                                "University of Wisconsin-River Falls",
                                
                                "University of Wisconsin-Stevens Point",
                                
                                "University of Wisconsin-Stout",
                                
                                "University of Wisconsin-Superior",
                                
                                "University of Wisconsin-Whitewater",
                                
                                "University of Wyoming",
                                
                                "Upper Iowa University",
                                
                                "Utah State University",
                                
                                "Utah Valley State College",
                                
                                "Valley City State University",
                                
                                "Valdosta State University",
                                
                                "Valparaiso University",
                                
                                "Vanderbilt University",
                                
                                "Vassar College",
                                
                                "Vermont Technical College",
                                
                                "Villa Julie College",
                                
                                "Villanova University",
                                
                                "Virginia Commonwealth University",
                                
                                "Virginia Intermont College",
                                
                                "Virginia Military Institute",
                                
                                "Virginia Polytechnic Institute and State University",
                                
                                "Virginia State University",
                                
                                "Virginia Wesleyan College",
                                
                                "Wabash College",
                                
                                "Wake Forest University",
                                
                                "Walden University",
                                
                                "Walla Walla College",
                                
                                "Warren Wilson College",
                                
                                "Wartburg College",
                                
                                "Washburn University",
                                
                                "Washington Bible College/Capital Bible Seminary",
                                
                                "Washington and Lee University",
                                
                                "Washington College",
                                
                                "Washington State University",
                                
                                "Washington State University at Tri-Cities",
                                
                                "Washington State University at Vancouver",
                                
                                "Washington University, Saint Louis",
                                
                                "Wayne State University",
                                
                                "Waynesburg College",
                                
                                "Weber State University",
                                
                                "Webster University",
                                
                                "Wellesley College",
                                
                                "Wells College",
                                
                                "Wentworth Institute of Technology",
                                
                                "Wesley College",
                                
                                "Wesleyan University",
                                
                                "West Chester University of Pennsylvania",
                                
                                "West Coast University",
                                
                                "West Georgia College",
                                
                                "West Liberty State College",
                                
                                "West Texas A&M University",
                                
                                "West Virginia University",
                                
                                "West Virginia University at Parkersburg",
                                
                                "Western Carolina University",
                                
                                "Western Connecticut State University",
                                
                                "Western Illinois University",
                                
                                "Western Kentucky University",
                                
                                "Western Maryland College",
                                
                                "Western Michigan University",
                                
                                "Western Montana College",
                                
                                "Western New England College",
                                
                                "Western New Mexico University",
                                
                                "Western State College",
                                
                                "Western Washington University",
                                
                                "Westfield State College",
                                
                                "Westminster College",
                                
                                "Westminster College",
                                
                                "Westminster College of Salt Lake City",
                                
                                "Westminster Theological Seminary",
                                
                                "Westmont College",
                                
                                "Wheaton College",
                                
                                "Wheaton College, Norton MA",
                                
                                "Wheeling Jesuit College",
                                
                                "Whitman College",
                                
                                "Whittier College",
                                
                                "Whitworth College",
                                
                                "Wichita State University",
                                
                                "Widener University",
                                
                                "Wilberforce University",
                                
                                "Wilkes University",
                                
                                "Willamette University",
                                
                                "William Howard Taft University",
                                
                                "William Jewell College",
                                
                                "William Mitchell College of Law",
                                
                                "William Penn College",
                                
                                "William Paterson College",
                                
                                "William Woods University",
                                
                                "Williams College",
                                
                                "Wilmington College",
                                
                                "Winona State University",
                                
                                "Winthrop University",
                                
                                "Wittenberg University",
                                
                                "Wofford College",
                                
                                "Woodbury University",
                                
                                "Worcester Polytechnic Institute",
                                
                                "Wright State University",
                                
                                "Xavier University of Louisiana",
                                
                                "Yale University",
                                
                                "Yeshiva University",
                                
                                "York College of Pennsylvania",
                                
                                "Youngstown State University"
        
    )
    
    let schoolTF: UITextField = {
        let tf = NameTextField()
        
        tf.placeholder = "School"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Select Your School/Alma Mater"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
         label.textColor = .white
        
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Please select your school/alma mater"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        return button
    }()
    
    var age = Int()
  var phone: String!
        
    @objc fileprivate func handleDone() {
        if schoolTF.text == "" {
            errorLabel.isHidden = false
            return
        }
        else {
         
            self.school = self.schoolTF.text ?? ""
            let bioController = YourSexController()
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["School": self.school]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
//            bioController.name = name
//            bioController.school = school
//            bioController.birthday = birthday
//            bioController.age = age
//            bioController.phone = phone
            self.present(bioController, animated: true)
        
            
        }
        
    }
    
    var user: User?
    var birthday = String()
    var school = String()
    
    var name = String()
    
     var schoolPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoolPicker.delegate = self
        schoolTF.inputView = schoolPicker
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [schoolTF, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 10, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
        
        
        
    }
    
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let bottomColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
}
