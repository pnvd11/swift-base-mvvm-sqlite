**1. Why using sqlite DB?**
- Because this will useful  for hybrid framework in next time coding.

**2. Why using MVVM pattern?**
- MVVM pattern is familiar with android platform. This is, again,  convenient  for using framework for both iOS and Android platforms

**3. About this app architecture:**
- project uses clean architecture with MVVM pattern
- SwiftBaseMVVM
*   Application: config app
*   Presenter: UI layer with MVVM pattern
*   Domain:  model layer + interface of Data 
* Data: business( logic) layer ( i.e: api services, repozitory for db) 
* Common: network lib + Sqlite DB
*   Resources
*   SQLite
*   SQLiteWrapper

**4. What’s Next!**
- Next Step should be hybrid framework.

**5. References:**

i. [Kodeco Sqlite tutorial.](https://www.kodeco.com/6620276-sqlite-with-swift-tutorial-getting-started)

ii. [Stephencelis Sqlite gitHub.](https://github.com/stephencelis/SQLite.swift/tree/master/Sources/SQLite)

iii. [FahimF Sqlite github](https://github.com/FahimF/SQLiteDB)


iv. [Kudoleh clean architecture](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)
