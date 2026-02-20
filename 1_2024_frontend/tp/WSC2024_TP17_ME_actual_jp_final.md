# Test Project  Module E Photos Slideshow

## *Web Technologies*

Independent Test Project Designer: Thomas Seng Hin Mak SCM

Independent Test Project Validator: Fong Hok Kin

# **Contents**

1. [**Introduction	3**](#introduction)
2. [**Description of project and tasks	3**](#description-of-project-and-tasks)

   1. [Loading photos	3](#loading-photos)
   2. [Configuration	3](#configuration)
   3. [Themes	4](#themes)
   4. [Command bar	5](#command-bar)

3. [**Instructions to the Competitor	5**](#instructions-to-the-competitor)
4. [**Other	5**](#other)

# **Introduction**  {#introduction}

In this project, a client asks you to create a photo slideshow tool.

User is able to load external photos, or load sample photos into the slideshow. Then, photos appear, stay for several seconds, and disappear, one by one. There may have transition and animation for appearing and disappearing of photos, depending on the theme applied.

The project should be reachable at [http://wsXX.worldskills.org/XX\_module\_e/](http://wsXX.worldskills.org/XX_module_e/).

# **Description of project and tasks** {#description-of-project-and-tasks}

There are different modes for the photo slideshow playing:

* Manual mode with left and right keyboard keypress.
* Auto-playing that photos keep coming in, and loop to the first photo after the last photo shows.
* Random playing the photos, which randomly a new photo shows after several seconds. In this mode, the slideshow runs forever and never ends.

The photo slideshow can also be turned into full screen browsing. The browser toolbar and windows task bar are hidden after full-screen.

## **Loading photos** {#loading-photos}

User can load photos by dragging the photo files into the drop area. Then these photos are displayed and played according to the theme animation.

When the CSS is not available, or if CSS is disabled, user can still select the photo files via the file input. The photos will then be loaded and listed into the web page. And no styles needed to apply.

### **Captions**

The caption of the photos is defined by the filename. Please capitalize the remove slug of the filename. And the caption doesn't contain a file extension.

For example, given a filename named "hello.jpg", the caption is Hello.

For example, the caption for "hello world.jpg" will be "Hello World".

For example, the caption for the "a-sample-photo.jpg" will be "A Sample Photo".

## **Configuration** {#configuration}

There is a configuration panel. There are three configuration parts in the panel: operating mode, the active theme switching, and the sorting of the photos.

### **Switching operating**

In the panel, user can switch between 3 operating modes: manual control, auto-playing, random playing.

### **Switching theme**

In the panel, user can switch between A to F theme.

### **Ordering photos**

In this configuration panel, user can order the selected photos by drag and drop the photos.

## **Themes** {#themes}

The first 5 themes are pre-defined, they are Theme A, B, C, D, and E. Then you are going to create your own Theme F.

### **Theme A**

Theme A displays the photos and captions directly, without any effects.

### **Theme B**

The active photo goes from left to right to the middle, then the photo goes from the middle to the right to leave the screen.

For the caption, the caption element follows the left-to-right animation, but with a delay of 300ms to start the animation.

Please find the theme-b-demo.mp4 from the media files for reference.

### **Theme C**

The active photo goes from bottom to top to the middle, then the photo goes from middle to the top to leave the screen.

For the caption, the caption is separated into words and each word animates up with a 300ms delay each.

Please find the theme-c-demo.mp4 from the media files for reference.

### **Theme D**

The active photo slides in from the left to the middle of the screen. Then the photo stays in the middle. Next photos slides in and to be placed on top of the active photos.

Each photo has a random slight rotation between \-5 degree to 5 degree.

These photos should not take up all the screen space. They should be approximately 85% of the screen space. This should create a feeling of stack of photos, because of the different rotation of the photos.

Each photo has a 3px of white border, with border radius 5px. And the bottom border looks thicker because of the caption. For the caption, it should be at the bottom of the photos, with background color sharing the same white color of the photo border.

Please find the theme-d-demo.mp4 from the media files for reference.

### **Theme E**

The active photo is displayed in the middle of the screen. Then there is a door opening effect for the current photo. The active photo is split into two halves, left half and right half part of the photo. Then the left and right half of the photo rotate into the screen with 3D perspective to create a door opening effect.

The next photo appears from the back to the front and become active after the current photo disappear.

In this theme, no photo captions are displayed.

Please find the theme-e-demo.mp4 from the media files for reference.

### **Theme F**

Please create a new them named "Theme F". You can define your photo sliding transition and captions animation. Please make sure they are appealing.

### **Sample photos**

There is an option to load sample photos instead of dragging in custom photos.

## **Command bar**

User can show command bar by pressing CTRL+K or "/". And user can return to normal from command bar dialog by pressing ESC key.

The command bar is usually placed in the middle of the screen. When the command bar is activated, the other part of the web page is dimmed.

During command bar is presented, different options are displayed under the command bar input.

When the command bar is activated, the other part of the web page is dimmed.

User can select different options by pressing keyboard up and down.

The selected option should be highlighted for user to know.

When user press ENTER key, the selected option is executed as the command.

There are following commands in the command bar:

* Change to manual control mode
* Change to auto-playing mode
* Change to random playing mode
* Switch to theme A
* Switch to theme B
* Switch to theme C
* Switch to theme D
* Switch to theme E
* Switch to theme F

# **Instructions to the Competitor** {#instructions-to-the-competitor}

CSS for the themes should be well organized into different files for easy maintenance and considered separate of concern.

# **Other** {#other}

The project should be reachable at http://wsXX.worldskills.org/XX\_module\_e/ URL.
If you have put your work in sub-folders, or in other port such as :3000, you may redirect to the destination from the /XX\_module\_e/ path.

You may provide a README file for executing guide if necessary.

This project will be assessed with either Firefox Developer Edition or Google Chrome web browser.

### **Marking Summary**

|  | Sub-Criteria | Marks |
| :---- | :---- | :---- |
| 1 | Loading image files | 2.75 |
| 2 | Ordering photos | 1.5 |
| 3 | Slides Operating | 2.5 |
| 4 | Theme | 6.5 |
| 5 | Command Bar | 3.75 |
