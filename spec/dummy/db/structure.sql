CREATE TABLE "error_duplicators" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" text, "body" text, "published" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "example_prgs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" text, "body" text, "published" boolean, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "index_error_duplicators_on_subject" ON "error_duplicators" ("subject");
CREATE UNIQUE INDEX "index_example_prgs_on_subject" ON "example_prgs" ("subject");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20140225004609');

INSERT INTO schema_migrations (version) VALUES ('20140225070319');
