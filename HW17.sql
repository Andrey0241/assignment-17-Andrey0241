-- Drop existing tables if they exist
DROP TABLE IF EXISTS Track;
DROP TABLE IF EXISTS CD;
DROP TABLE IF EXISTS Artist;

-- Create the Artist table
CREATE TABLE Artist (
    artID SERIAL NOT NULL,
    artName VARCHAR(255) NOT NULL,
    CONSTRAINT pk_artist PRIMARY KEY (artID),
    CONSTRAINT ck_artist UNIQUE (artName)
);

-- Create the CD table
CREATE TABLE CD (
    cdID SERIAL NOT NULL,
    artID BIGINT UNSIGNED NOT NULL,
    cdTitle VARCHAR(255) NOT NULL,
    cdPrice REAL NOT NULL,
    cdGenre VARCHAR(255) NULL,
    cdNumTracks INT NULL,
    CONSTRAINT pk_cd PRIMARY KEY (cdID),
    CONSTRAINT fk_cd_art FOREIGN KEY (artID) REFERENCES Artist (artID)
);
-- Insert values into Artist table
INSERT INTO Artist (artName)
VALUES  ('Muse'),
        ('Mr. Scruff'),
        ('DeadMau5'),
        ('Mark Ronson'),
        ('Mark Ronson & The Business Intl'),
        ('Animal Collective'),
        ('Kings of Leon'),
        ('Maroon 5');

-- Insert values into CD table
INSERT INTO CD (artID, cdTitle, cdGenre, cdPrice)
VALUES
((SELECT artID from Artist WHERE artName = 'Muse'), 'Black Holes and Revelations', 'Rock', 9.99),
((SELECT artID from Artist WHERE artName = 'Muse'), 'The Resistance', 'Rock', 11.99),
((SELECT artID from Artist WHERE artName = 'Mr. Scruff'), 'Ninja Tuna', 'Electronica', 9.99),
((SELECT artID from Artist WHERE artName = 'DeadMau5'), 'For Lack of a Better Name', 'Electro House', 9.99),
((SELECT artID from Artist WHERE artName = 'Mark Ronson'), 'Version', 'Pop', 12.99),
((SELECT artID from Artist WHERE artName = 'Mark Ronson & The Business Intl'), 'Record Collection', 'Alternative Rock', 11.99),
((SELECT artID from Artist WHERE artName = 'Animal Collective'), 'Merriweather Post Pavilion', 'Electronica', 12.99),
((SELECT artID from Artist WHERE artName = 'Kings of Leon'), 'Only By The Night', 'Rock', 9.99),
((SELECT artID from Artist WHERE artName = 'Kings of Leon'), 'Come Around Sundown', 'Rock', 12.99),
((SELECT artID from Artist WHERE artName = 'Maroon 5'), 'Hands All Over', 'Pop', 11.99);

-- 1.Find a list of CD titles and prices where the title contains exactly one word

SELECT cdTitle, cdPrice
FROM CD
WHERE cdTitle NOT LIKE '% %';

-- 2.Find all CD titles and the corresponding artist names where title contains the string “ro”

SELECT CD.cdTitle, Artist.artName
FROM CD
JOIN Artist ON CD.artID = Artist.artID
WHERE cdTitle LIKE '%ro%';

-- 3.Find all the information from CD where title contains the letters “he” containing the single character at the beginning

SELECT *
FROM CD
WHERE cdTitle LIKE '_he%';

-- 4.Use a subquery to find a list of CDs that have the same genre as ‘Version’

SELECT cdTitle
FROM CD
WHERE cdGenre = (SELECT cdGenre FROM CD WHERE cdTitle = 'Version');

-- 5.Use IN to find a list of the titles of albums that are the same price as any ‘Electronica’ album

SELECT cdTitle
FROM CD
WHERE cdPrice IN (SELECT cdPrice FROM CD WHERE cdGenre = 'Electronica');

-- 6.Use ANY to find the titles of CDs that cost less than at least one other CD

SELECT cdTitle
FROM CD
WHERE cdPrice < ANY (SELECT cdPrice FROM CD);

-- 7.Use ALL to find a list of CD titles with the least price

SELECT cdTitle
FROM CD
WHERE cdPrice <= ALL (SELECT cdPrice FROM CD);

-- 8.Use EXISTS to find a list of Artists who produced a “Pop” CD

SELECT artName
FROM Artist
WHERE EXISTS (SELECT 1 FROM CD WHERE Artist.artID = CD.artID AND cdGenre = 'Pop');

-- 9.Find the names of Artists who have albums of “Rock” category. Provide at least two different queries producing the same solution

SELECT artName
FROM Artist
WHERE artID IN (SELECT artID FROM CD WHERE cdGenre = 'Rock');

-- 10.Find names of CDs produced by those Artists who have at least two words as their name

SELECT cdTitle
FROM CD
WHERE artID IN (SELECT artID FROM Artist WHERE artName LIKE '% %');

-- 11.Find all information about CDs which are cheaper than others in the ‘Rock’ and ‘Pop’ categories only

SELECT *
FROM CD
WHERE cdPrice < ALL (SELECT cdPrice FROM CD WHERE cdGenre IN ('Rock', 'Pop'));

-- 12.Find the Artist names and their ID (in this order) for albums which cost £12.99. Provide three different queries producing the same solution

SELECT artName, artID
FROM Artist
WHERE artID IN (SELECT artID FROM CD WHERE cdPrice = 12.99);


-- 13.List the cd titles in reverse alphabetical order

SELECT cdTitle
FROM CD
ORDER BY cdTitle DESC;

-- 14.List the titles, genres and prices of CDs in order of price from lowest to highest

SELECT cdTitle, cdGenre, cdPrice
FROM CD
ORDER BY cdPrice ASC;

-- 15.List the titles, genres and prices of CDs in order of price from highest to lowest

SELECT cdTitle, cdGenre, cdPrice
FROM CD
ORDER BY cdPrice DESC;

-- 16.List the titles, genres and prices of CDs in alphabetical order by genre, then by price from the highest price to the lowest one

SELECT cdTitle, cdGenre, cdPrice
FROM CD
ORDER BY cdGenre ASC, cdPrice DESC;

-- 17.Find a list of artist names, the number of CDs they have produced, and the average price for their CDs. Only return results for artists with more than one CD

SELECT Artist.artName, COUNT(CD.cdID) AS numCDs, AVG(CD.cdPrice) AS avgPrice
FROM CD
JOIN Artist ON CD.artID = Artist.artID
GROUP BY Artist.artName
HAVING COUNT(CD.cdID) > 1;

-- 18.Find a list of artist names, the number of CDs by that artist and the average price for their CDs but not including ‘Electronica’ albums (you might like to use a WHERE in this one too)

SELECT Artist.artName, COUNT(CD.cdID) AS numCDs, AVG(CD.cdPrice) AS avgPrice
FROM CD
JOIN Artist ON CD.artID = Artist.artID
WHERE cdGenre != 'Electronica'
GROUP BY Artist.artName;

-- 19.Find the difference between the average price of the rock albums and the average price of all albums excluding Muse’s CDs (ABS() will produce the absolute value of a calculation)

SELECT ABS((SELECT AVG(cdPrice) FROM CD WHERE cdGenre = 'Rock') -
           (SELECT AVG(cdPrice) FROM CD WHERE artID != (SELECT artID FROM Artist WHERE artName = 'Muse')));

-- 20.Find the artist name(s) with the most expensive CDs by average

SELECT Artist.artName
FROM CD
JOIN Artist ON CD.artID = Artist.artID
GROUP BY Artist.artName
ORDER BY AVG(CD.cdPrice) DESC
LIMIT 1;

-- 21.Find the most expensive genre of music by calculating the minimum of the averages of all genres

SELECT cdGenre
FROM CD
GROUP BY cdGenre
ORDER BY AVG(cdPrice) DESC
LIMIT 1;

-- 22.Find a list of artist names, the number of CDs by that artist and the average price for their CDs but not including ‘Pop’ albums

SELECT Artist.artName, COUNT(CD.cdID) AS numCDs, AVG(CD.cdPrice) AS avgPrice
FROM CD
JOIN Artist ON CD.artID = Artist.artID
WHERE cdGenre != 'Pop'
GROUP BY Artist.artName;
