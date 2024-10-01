CREATE TYPE "order_status" AS ENUM (
  'created',
  'pending',
  'cancelled',
  'finished'
);

CREATE TABLE "users" (
  "id" serial UNIQUE PRIMARY KEY,
  "login" varchar(64) NOT NULL,
  "is_admin" bool DEFAULT false,
  "name" varchar(30) NOT NULL,
  "surname" varchar(30) NOT NULL,
  "password" varchar(64) NOT NULL,
  "card_id" int UNIQUE NOT NULL
);

CREATE TABLE "filter_category" (
  "id" serial UNIQUE PRIMARY KEY,
  "name" varchar(32) NOT NULL,
  "createdAt" timestamp NOT NULL DEFAULT (now()),
  "updatedAt" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "sizes" (
  "id" serial UNIQUE PRIMARY KEY,
  "name" varchar(32) NOT NULL,
  "createdAt" timestamp NOT NULL DEFAULT (now()),
  "updatedAt" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "categories" (
  "id" serial UNIQUE PRIMARY KEY,
  "name" varchar(64) NOT NULL,
  "filter_id" int NOT NULL,
  "createdAt" timestamp NOT NULL DEFAULT (now()),
  "updatedAt" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "goods" (
  "id" serial UNIQUE PRIMARY KEY,
  "category_id" int NOT NULL,
  "name" varchar(30) NOT NULL,
  "createdAt" timestamp NOT NULL DEFAULT (now()),
  "updatedAt" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "good_variants" (
  "id" serial UNIQUE PRIMARY KEY,
  "good_id" int NOT NULL,
  "size" int NOT NULL,
  "price" float NOT NULL
);

CREATE TABLE "orders" (
  "id" serial UNIQUE PRIMARY KEY,
  "user_id" int NOT NULL,
  "status" order_status NOT NULL DEFAULT 'created',
  "createdAt" timestamp NOT NULL DEFAULT (now()),
  "updatedAt" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "card_item" (
  "id" serial UNIQUE PRIMARY KEY,
  "user_id" int UNIQUE NOT NULL,
  "count" int DEFAULT 1
);

ALTER TABLE "goods" ADD CONSTRAINT "unique_goods_fileds" UNIQUE ("category_id", "name");

ALTER TABLE "good_variants" ADD FOREIGN KEY ("size") REFERENCES "sizes" ("id") ON DELETE CASCADE;

ALTER TABLE "categories" ADD FOREIGN KEY ("filter_id") REFERENCES "filter_category" ("id") ON DELETE CASCADE;

ALTER TABLE "good_variants" ADD FOREIGN KEY ("good_id") REFERENCES "goods" ("id") ON DELETE CASCADE;

ALTER TABLE "orders" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE;

ALTER TABLE "goods" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id") ON DELETE CASCADE;

ALTER TABLE "users" ADD FOREIGN KEY ("card_id") REFERENCES "card_item" ("user_id") ON DELETE CASCADE;

CREATE TABLE "sizes_filter_category" (
  "sizes_id" serial,
  "filter_category_id" serial,
  PRIMARY KEY ("sizes_id", "filter_category_id")
);

ALTER TABLE "sizes_filter_category" ADD FOREIGN KEY ("sizes_id") REFERENCES "sizes" ("id");

ALTER TABLE "sizes_filter_category" ADD FOREIGN KEY ("filter_category_id") REFERENCES "filter_category" ("id");


CREATE TABLE "goods_orders" (
  "goods_id" serial,
  "orders_id" serial,
  PRIMARY KEY ("goods_id", "orders_id")
);

ALTER TABLE "goods_orders" ADD FOREIGN KEY ("goods_id") REFERENCES "goods" ("id");

ALTER TABLE "goods_orders" ADD FOREIGN KEY ("orders_id") REFERENCES "orders" ("id");


CREATE TABLE "card_item_goods" (
  "card_item_id" serial,
  "goods_id" serial,
  PRIMARY KEY ("card_item_id", "goods_id")
);

ALTER TABLE "card_item_goods" ADD FOREIGN KEY ("card_item_id") REFERENCES "card_item" ("id");

ALTER TABLE "card_item_goods" ADD FOREIGN KEY ("goods_id") REFERENCES "goods" ("id");

CREATE FUNCTION valid_sizes (int,int) RETURNS BOOLEAN AS
'SELECT $1 IN (SELECT sizes_id from sizes_filter_category where filter_category_id=(SELECT filter_id from categories INNER JOIN goods ON categories.id=goods.category_id WHERE goods.id = $2))'
LANGUAGE SQL
IMMUTABLE;

ALTER TABLE "good_variants" ADD CONSTRAINT "size_check" CHECK (valid_sizes(size,good_id));

/*SELECT 1 IN (SELECT sizes_id from sizes_filter_category where filter_category_id=(SELECT filter_id from categories INNER JOIN goods ON categories.id=goods.category_id INNER JOIN good_variants ON goods.id = good_variants.good_id where good_variants.id=26));
*/
/*ALTER TABLE "good_variants" ADD CONSTRAINT "size_check" CHECK (size IN (1,2,3,4));
*/
--ALTER TABLE good_variants ADD CHECK (size  '');
