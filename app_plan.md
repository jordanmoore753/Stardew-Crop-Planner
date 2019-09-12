# Database Design

Crops table.

1. id serial PRIMARY KEY
2. name text NOT NULL UNIQUE
3. season integer NOT NULL
4. until_harvest integer NOT NULL
5. regrow integer NOT NULL

Crop prices table.

1. id serial PRIMARY KEY
2. crop_id integer REFERENCES crops (id) ON DELETE CASCADE
3. sell_price integer NOT NULL
4. seed_price integer NOT NULL

Planted crops table.

Calculate the specific days on which there will be regrows and first harvest. The first harvest will be a single integer, whereas, regrows will be an array of 1 or more values (or just NULL). Regrows can be calculated by invoking a loop. 

Current_day variable is set equal to the value of the first_harvest (which is equal to the day of planting + first_harvest (from crops table)). Then, on each iteration of the loop, increment the value of current_day by the regrowth rate (sub_harvest). If the number is greater than 28, break and don't add the current_day value to the array; however, if number is less than or equal to 28, append the current value to the array. This array will be inserted into the planted crops table.

1. id serial PRIMARY KEY
2. crop_id integer REFERENCES crops (id) ON DELETE CASCADE
3. season_id integer REFERENCES crops (season) ON DELETE CASCADE
4. planted_on integer 
5. first_harvest integer
6. sub_harvests integer[] 
7. amount integer NOT NULL

```sql
CREATE TABLE users (
id serial PRIMARY KEY,
name text NOT NULL UNIQUE,
password text NOT NULL
);

CREATE TABLE seasons (
id serial PRIMARY KEY,
name text NOT NULL UNIQUE
);

CREATE TABLE crops (
id serial PRIMARY KEY,
name text NOT NULL UNIQUE,
season integer REFERENCES seasons (id) ON DELETE CASCADE,
until_harvest integer NOT NULL,
regrow integer,
produces integer NOT NULL
);

CREATE TABLE crop_prices (
id serial PRIMARY KEY,
crop_id integer REFERENCES crops (id) ON DELETE CASCADE,
sell_price integer NOT NULL,
seed_price integer NOT NULL
);

CREATE TABLE planted_crops (
id serial PRIMARY KEY,
crop_id integer REFERENCES crops (id) ON DELETE CASCADE,
season_id integer NOT NULL,
planted_on integer,
first_harvest integer,
sub_harvests integer[],
amount_planted integer NOT NULL,
user_id integer REFERENCES users (id) ON DELETE CASCADE
);

INSERT INTO planted_crops (crop_id, season_id, planted_on, first_harvest, sub_harvests, amount_planted, user_id)
VALUES (5, 1, 1, 11, ARRAY [14, 17, 20, 23, 26], 23, 1);
/* insertions */

INSERT INTO seasons (name)
VALUES ('Spring'), ('Summer'), ('Fall'), ('Winter');

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Blue Jazz', 1, 7, NULL, 1),
('Cauliflower', 1, 12, NULL, 1),
('Coffee Bean', 1, 10, 2, 4),
('Garlic', 1, 4, NULL, 4),
('Green Bean', 1, 10, 3, 1),
('Kale', 1, 6, NULL, 1),
('Parsnip', 1, 4, NULL, 1),
('Potato', 1, 6, NULL, 1),
('Rhubarb', 1, 13, NULL, 1),
('Strawberry', 1, 8, 4, 1),
('Tulip', 1, 6, NULL, 1);

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Blueberry', 2, 13, 4, 3),
('Corn', 2, 14, 4, 1),
('Hops', 2, 11, 1, 1),
('Hot Pepper', 2, 5, 3, 1),
('Melon', 2, 12, NULL, 1),
('Poppy', 2, 7, NULL, 1),
('Radish', 2, 6, NULL, 1),
('Red Cabbage', 2, 9, NULL, 1),
('Starfruit', 2, 13, NULL, 1),
('Summer Spangle', 2, 8, NULL, 1),
('Sunflower', 2, 8, NULL, 1),
('Tomato', 2, 11, 4, 1),
('Wheat', 2, 4, NULL, 1);

INSERT INTO crops(name, season, until_harvest, regrow, produces)
VALUES ('Amaranth', 3, 7, NULL, 1),
('Artichoke', 3, 8, NULL, 1),
('Beet', 3, 6, NULL, 1),
('Bok Choy', 3, 4, NULL, 1),
('Cranberries', 3, 7, 5, 2),
('Eggplant', 3, 5, 5, 1),
('Fairy Rose', 3, 12, NULL, 1),
('Grape', 3, 10, 3, 1),
('Pumpkin', 3, 13, NULL, 1),
('Yam', 3, 10, NULL, 1);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (1, 50, 30),
(2, 175, 80),
(3, 15, 2500),
(4, 60, 40),
(5, 40, 60),
(6, 110, 70),
(7, 35, 20),
(8, 80, 50),
(9, 220, 100),
(10, 120, 100),
(11, 30, 20);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (12, 50, 80),
(13, 50, 150),
(14, 25, 60),
(15, 40, 40),
(16, 250, 80),
(17, 140, 100),
(18, 90, 40),
(19, 260, 100),
(20, 750, 450),
(21, 90, 50),
(22, 80, 200),
(23, 60, 50),
(24, 25, 10);

INSERT INTO crop_prices (crop_id, sell_price, seed_price)
VALUES (25, 150, 70),
(26, 160, 30),
(27, 100, 20),
(28, 80, 50),
(29, 75, 240),
(30, 60, 20),
(31, 290, 200),
(32, 80, 60),
(33, 320, 100),
(34, 160, 60);


```

## 9/12

Working on responsiveness. I can't cover all screens super well, but I can assume that people will have a phone, tablet, or laptop. The smallest width I can cover while keeping the calendar look okay is 667px. The next step up (iPad) is 1024px.

667px and lower: calendar has 3 grid cells per row. 
1024px and lower: calendar has 4 grid cells per row.
1280px and up: calendar has 7 grid cells per row.

All screen sizes: The banner will be changed to the current season but with no click arrows to navigate to other routes. The fixed nav is going to be fixed to the bottom of the screen so scrolling isn't an issue. The only reason you would need to scroll are to see certain crops in higher dates in the season.

I think the nav should take up the full width for 667 and lower. Then, it should take up 667px exactly for the rest of the widths.

/

This is the old code for the form, gets pasted on line 61:

<div class="form-container">
    <div class="calendar-grid-form-container">
      <div class="add-crop-form">
        <h5>Add Plants</h5>
        <form action="/add_crop_calendar" method="post">
          <ul class="form-list">
            <li class="input-label-item">Crop Name</li>
            <li>
              <select class="input-calendar" name="crop_name" required>
                <% @crops.each do |crop| %>
                  <option><%= crop[:name] %></option>
                <% end %>
              </select>
            </li>
            <li class="input-label-item">Date Planted</li>
            <li>
              <select class="input-calendar" name="plant_date" required>
                <% available_planting_days.each do |num| %>
                  <option><%= num %></option>
                <% end %>
              </select>
            </li>
            <li class="input-label-item">Amount Planted</li>
            <li>
              <input class="input-calendar" type="number" max="1000" min="1" name="amount_planted" required >
            </li>
          </ul>
          <input type="submit" value="Add Crop">
        </form>
      </div>
      <div class="delete-crop-form">
        <form action="/<%= @season %>/delete_single_crop" method="post">
          <h5>Remove Plants</h5>
          <ul class="form-list">
            <li class="input-label-item">Crop Name</li>
            <li>
              <select class="input-calendar" name="id">
                <% @planted_crops.each do |crop| %>
                  <option value="<%= crop[:id] %>"><%= return_crop_name(crop[:crop_id]) %>, First Harvest: <%= crop[:first_harvest] %></option>
                <% end %>
              </select>
            </li>
            <li class="input-label-item">
              <input class="input-calendar" type="submit" value="Delete Single Crop">
            </li>
          </ul>
        </form>
        <form action="/<%= @season %>/delete_season_crops" method="post">
          <ul class="form-list">
            <li class="input-label-item">Delete All Crops</li>
            <li>
              <input class="input-calendar" type="submit" value="Delete Crops">
            </li>
          </ul>
        </form>
      </div>
      <div class="return-home-form">
        <h5>Notes</h5>
        <p class="return-home-paragraph">To change seasons, click the "<b><<</b>" or "<b>>></b>" buttons up in the top-left of this page.</span></p>
        <h5 class="idx-return-heading">Return to Index</h5>
        <ul class="form-list">
          <li style="text-align: center;">
            <a href="/"><img src="/img/player.png"></a>
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

This is old code for banner, pastedon line 1.

<div class="mobile-container-banner">
  <div class="banner-container-cal">
    <div class="banner-links-container">
    <ul class="banner-links">
      <li class="banner-container-link">
        <a href="/calendar/<%= display_before_season %>"><<</a>
      </li>
      <li class="banner-container-heading"><%= @season %></li>
      <li class="banner-container-link">
        <a href="/calendar/<%= display_after_season %>">>></a>
      </li> 
    </ul>
  </div>
  </div>
  <div class="header-container">
    <div class="banner-container-heading">
      <h2 class="banner-heading">Stardew Valley Crop Planner</h2>
    </div>
  </div>
  <div class="banner-profit-container">
    <p class="banner-profit-cal">Profit: <span class="profit-number">$<%= @profit %></span></p>
  </div>  
</div>