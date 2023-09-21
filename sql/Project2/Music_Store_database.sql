-- Who is the senior most employee based on job title?
select * from employee
Order by levels desc
limit 1

-- Which countries have the most Invoices?
select billing_country, count(*) as c
from invoice
group by billing_country
order by c desc
limit 1

-- What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals 
select billing_city, SUM(total) as InvoiceTotal
from invoice
Group by billing_city
ORDER by InvoiceTotal DESC
LIMIT 1;

--  Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select customer.customer_id, first_name, last_name, SUM(total) as total_spending
from customer 
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_spending DESC
limit 1

-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

--method 1
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
    select track_id from track
    join genre on track.genre_id = genre.genre_id
    where genre.name LIKE 'Rock'
)
order by email; -- in this query we cant return the genre 

--method 2
select distinct email as Email, first_name as FirstName, last_name as LastName, genre.name as GenreName
from customer
JOIN invoice ON invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name Like 'Rock'
order by email; -- in this query all the columns are returned which are required

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
select artist.artist_id, artist.name as Name, COUNT(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs DESC
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds 
from track
where milliseconds > (
    select avg(milliseconds) As avg_track_length
    from track
)
order by milliseconds DESC;


/* Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

with best_selling_artist as (
    Select artist.artist_id as artist_id, artist.name as artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
    from invoice_line
    join track on track.track_id = invoice_line.track_id
    join album on album.album_id = track.album_id
    join artist on artist.artist_id = album.artist_id
    group by 1
    order by 3 desc
    limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum()