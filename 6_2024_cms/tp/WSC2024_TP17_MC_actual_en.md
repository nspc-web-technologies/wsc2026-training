# Test Project Module C: Lyon Heritage Sites

Web Technologies

Independent Test Project Designer: Thomas Seng Hin Mak SCM
Independent Test Project Validator: Fong Hok Kin

## Table of Contents

- [Introduction](#introduction)
- [Description of Project and Tasks](#description-of-project-and-tasks)
  - [URL Routes and Mapping](#url-routes-and-mapping)
  - [Filename Convention](#filename-convention)
  - [Listing Content](#listing-content)
    - [Ordering of Content Listing](#ordering-of-content-listing)
  - [Accessing Content Pages](#accessing-content-pages)
    - [Front-matter](#front-matter)
  - [Rendering a Heritage Site Web Page](#rendering-a-heritage-site-web-page)
    - [Cover Image](#cover-image)
    - [Cover Image Styling](#cover-image-styling)
    - [On the Extraction of Title](#on-the-extraction-of-title)
    - [Styling of the Title Section](#styling-of-the-title-section)
    - [Aside Information](#aside-information)
    - [Rendering Main Content](#rendering-main-content)
  - [Tags](#tags)
    - [Searching](#searching)
- [Instructions to the Competitor](#instructions-to-the-competitor)
  - [Marking Summary](#marking-summary)

## Introduction

Welcome to Lyon. This vibrant city is known for its historical significance and architectural beauty. In this project, some editors wrote some articles to introduce notable heritage sites in Lyon, France. Each article is written in `.html` or `.txt` format, with a front-matter embedded at the beginning of each article for meta information. These files are stored in a folder called `content-pages`. Some article files may be stored in sub-folders, or nested sub-folders.

There is one `images` folder under the `content-pages` folder. All image paths mentioned in these articles are all relative to this images folder. That means no images folder inside nested sub-folders. It means when referring to any image names in articles inside sub-folders, these images all refer to this images folder under the `content-pages` folder.

You are asked to create a website to host these articles. Each article becomes a "page", that we refer to in the following document. In order to keep the current article writing workflow, we will keep the existing structure of the `content-pages` folder unchanged.

In this module, we create a site that lists and loads these files and sub-folders. The site reads these static files from a `content-pages` folder and displays the content as web pages. The naming convention for the pages is `YYYY-MM-DD-title.txt`, or `YYYY-MM-DD-title.html`.

The website is reachable at `http://wsXX.worldskills.org/XX_module_C/`

XX is your seat number.

## Description of Project and Tasks

There is no need to use a database in this project. The content is stored in the `content-pages` folder, or sub-folders inside it. Anyone can access the home page and the heritage sites page. When accessing the home page, there should be a list of all pages and sub-folders.

### URL Routes and Mapping

There are URL route definitions for listing the content folder, pages, and querying tags.

The URL to each page or sub-folder is defined as following. XX is your seat number.

- `/XX_module_c/` shows the index listing.
- `/XX_module_c/heritages/2024-09-01-example-page` shows the page for `2024-09-01-example-page.html` or `2024-09-01-example-page.txt`
- `/XX_module_c/heritages/sub-folder-name` lists the pages and folders of the specific sub-folder.
- `/XX_module_c/heritages/sub-folder-name/2024-09-10-welcome-to-lyon` shows the page of `2024-09-10-welcome-to-lyon.html` or `2024-09-10-welcome-to-lyon.txt` in the `sub-folder-name` folder.
- `/XX_module_c/heritages/sub-folder-1/sub-folder-2/2024-09-10-welcome-to-lyon` shows the page of `2024-09-10-welcome-to-lyon.html` or `2024-09-10-welcome-to-lyon.txt` in the `sub-folder-1/sub-folder-2/` folder.

The URL for tags querying is defined as following.

- `/XX_module_c/tags/tag-name-here` shows a page that lists all the pages that contain the given tag `tag-name-here`

Note: The paths above are relative to `http://wsXX.worldskills.org`

### Filename Convention

The filename contains the date, and the title in slug form. It is `YYYY-MM-DD-title-in-lower-case-with-hyphens.html`, or `.txt`.

The first part of the filename is in `YYYY-MM-DD` format: YYYY for the year in 4 digits, MM for months in 2 digits, and DD for day in 2 digits.

The second part of the filename is the title of the file, in slug form. That is a lower case of the title with all spaces replaced by hyphens.

Here are some sample filenames:

- `2024-09-01-example-page.html`
- `2024-10-20-greatest-lyon-heritage-site.html`
- `2025-01-01-a-post-for-future-posting.txt`

### Listing Content

When listing the content, the list shows the title and the summary. Clicking either on the title or summary will link to that single content.

The list should not list future pages, which are pages whose date is in the future, after today.

The list also should not list pages in draft state, where `draft` is `"true"` as defined in the front-matter of the file.

The list should also hide pages without any dates defined. That is when the first 11 characters are not in the format of `YYYY-MM-DD-`.

Aside from the pages, the list also lists and links to sub-folders. When clicking on the sub-folder name, the web lists the content within the sub-folder. That is the pages and sub-folders inside that sub-folder.

#### Ordering of Content Listing

The list lists sub-folders first, then it lists the content pages. The sub-folders are listed in alphabetical order. The content pages are listed in reversed alphabetical order. That will result in having the latest pages on the top and oldest pages at the bottom.

### Accessing Content Pages

Each file in the `content-pages` folder contains one heritage content. It includes a path to the cover image, tags, summary, and may include the title.

In each file, there are two parts: Front-matter, and the main content.

The front-matter is optional. If there is front-matter, it will be marked with `---` at both the beginning and ending of the front-matter section.

Here is an example content in `.html` extension, with front-matter embedded:

```
---
title: This is an Example Page
tags: example, test
cover: example-cover.jpeg
summary: This is a sample summary.
---
<h1>Example Page</h1>
<p>Here is the rest of the content.</p>
<p>And some other paragraph.</p>
<img src="hello-world.jpg" alt="Sample photo">
<footer>That is all</footer>
```

Here is an example content in `.txt` extension format:

```
---
title: This is another sample page
tags: example, test, plain-text
cover: another-cover.jpeg
summary: This is a sample page in txt format.
---
This is sample main content.
Each line of content is turned into <p></p> paragraph.
sample-image.jpeg
The image path / image name with individual line are turned into <img> tag.
This is footer paragraph.
```

The files in the `content-pages` folder can be nested into sub-folders.

#### Front-matter

There may be front-matter in the beginning of the content file.

There may be different key-value pairs defined in the front-matter section. They are:

- `title` (optional)
- `tags` (optional): separated by comma, or comma with spaces
- `draft` (optional): `true`, or other values. Any values other than `"true"` is considered as false.
- `summary` (optional): One line only. To be used when listing the pages.

### Rendering a Heritage Site Web Page

In the rendered page, there are the following sections:

- Cover image
- Title
- Aside information
- Main content

#### Cover Image

The path to the cover image of each content page is defined in the front-matter by default.

If the cover image is not defined in the front-matter, the cover image will be the same file name stored in the images folder. In this project, we don't need to consider the missing of this cover image.

#### Cover Image Styling

There is a subtle spotlight effect on the cover image.

A radial gradient mask is applied to the cover image. The mask is a circle with center point following the mouse pointer, gradient from `black` to `rgba(255,255,255,0)` at `300px`.

Please refer to the `cover-image-styling.mp4` in the media files.

#### On the Extraction of Title

There is a Title section after the cover image. The content of the title is decided according to the following criteria.

The title should be extracted from the following, in order:

1. When there is `title` defined in the front-matter, the content of the Title section uses the value of this front-matter.
2. When there is no `title` defined in the front-matter, the content of the Title section uses the text content of the first `<h1></h1>` (simple text content; the h1 will not contain rich HTML).
3. When there is no `title` in the front-matter and no `<h1>` tag in the content, the content of the Title section uses the capitalized form of the file name, without extension and the `YYYY-MM-DD` date portion. Also, all the hyphen slugs (`-`) are removed and replaced with spaces.

#### Styling of the Title Section

Please use the `common-ligatures` typography setting on the title styling.

#### Aside Information

There are following information in the aside information area:

- date
- tags
- draft (if the draft is `true`)

The meta information on the side is sticked to the top when scrolling down.

#### Rendering Main Content

The main content should be dynamically loaded from the files.

Here are some file loading strategies:

- If the file extension is `.html`, the main content and any HTML tags are rendered as-is. No need to parse or process (except the image path). They are just rendered as HTML.
- If the file extension is `.txt`, there will only be two kinds of content: lines of text and individual lines containing image paths. Each line of text is turned into HTML paragraphs.
- Individual lines of image paths are turned into image tags. These are lines without any spaces and with image extensions at the end.
- For both `.html` and `.txt`, the image paths should be replaced to fit final image paths that work on the server.

The photos in the content area have full-width to the main content container. The photos in the main content area can be enlarged when the user clicks on them. Clicking the enlarged photo will close it and revert to the main content. Scrolling during photo enlarged will also close the enlarged photo and revert to the main content.

The first letter of the first paragraph has a drop cap for 3 lines.

### Tags

Content pages can be filtered by tags. The URL for tags querying is defined as following:

`http://wsXX.worldskills.org/XX_module_c/tags/tag-name-here` shows a page that lists all the pages that contain the given tag `tag-name-here`.

#### Searching

The web page should be able to search for pages. Please provide a search input and user should be able to search for title or content. Given a search query, the web page should list pages where either the title or the content contains the query string.

It should be able to use `/` to define multiple keywords for searching. The page lists pages with a title or content that contains either keyword, in OR logic.

## Instructions to the Competitor

You may put your project in a sub-folder or different port. Please redirect to your destination from the path `wsXX.worldskills.org/XX_module_c/`.

For example, `/XX_module_c/heritages/sub-folder-name` may be `/XX_module_c/public/heritages/sub-folder-name` or `/XX_module_c/index.php/heritages/sub-folder-name` or `:3000/XX_module_c/heritages/sub-folder-name`.

Note: if you are using Node.js, please be aware that the `node_modules` files for Windows (on workstation) and Linux (on server) are different. Using a wrong `node_modules` folder may result in unexpected errors.

You may provide a README file for executing guide if necessary.

Please consider better accessibility. Full page scan will be performed by using the aXe accessibility dev tool.

Please define social sharing meta tags for each single heritage page for sharing friendly purpose.

Please define the `.gitignore` file to skip `node_modules` folder and other temporary folders or built folders.

This project will be assessed by using Google Chrome web browser.

### Marking Summary

| # | Sub-Criteria | Marks |
|---|---|---|
| 1 | Files and Listing | 7.0 |
| 2 | Search and Tags | 2.0 |
| 3 | Loading files | 5.5 |
| 4 | Layout | 6.75 |

Total: 21.25 marks
