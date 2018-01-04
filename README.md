## Mobile App Dev Kata - - Vending Machine ##

This repo contains the mobile application development kata for AEP. This kata's
overview is detailed in `Mobile Application Development Kata.doc` and the specifications
are detailed in `mobile-vending-machine-kata.txt`, both of which are included
in the repo.

## Tools being used ##
 * [SwiftLint](https://github.com/realm/SwiftLint): not necessary, being used
for style consistency.
 * No dependencies otherwise.

## Building this project locally ##
 * You will need Xcode installed on your system (this was built on 9.2 (9C40b)
 * Clone this repo to your system
 * Open the `.xcodeproj` with Xcode (`mobileAppKata > Vending Machine > VendingMachine.xcodeproj`)
 * To build and run on a simulated device, select the device you wish to run on and push the "run"
   button or press `CMD + R`

## Thoughts ##
 * Some basic thinking / planning can be found in the root of this repo, specifically
   `ui_design_v1.jpg` and `Vending Machine Kata.pdf`. I definitely have a strong
   preference for "whiteboard thinking", but I do like the mind-mapping process. I
   do not have a well-defined process I always follow, it changes as I learn.
 * The UI is VERY simplistic. I am by no means a designer, and although I could
   come up with something better looking eventually, I did not want to spend too
   much time on the UI right now. Might work on something prettier later.
 * Code documentation: I recently experienced Doxygen (and loved it) and wanted
   to try out Swift documentation as I worked on this. I like having the documentation
   inline, but frequently dislike the way it looks. I feel like I want to add whitespace
   but also don't like how that looks. Would like to find real-life code that 
   has good file structure, good documentation, good styling so I can head in the
   right direction.
 * Things I would do differently:
   * The first thing would probably be the `Machine` logic. I went back
     and forth on breaking things out into smaller classes, but then some would
     be tiny. Beyond that, the flow through that class could do with some refactoring,
     but I would need to spend some time thinking about that now that everything
     is together.
   * Better TDD in general. I have yet to work in a TDD environment, so I am often
     fighting against habit. I started off with the best intentions, but frequently
     wrote code before writing the tests and not writing "only what is needed to
     pass".
   * Along a similar vein, better git flow. I have a bad habit of tacking on extra
     modifications with an issue (things not necessarily related to that issue).
     Again, most of my git flow experience has been self-taught, so I feel I am
     lacking 'best practices' in this area.
