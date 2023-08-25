create table documents (
  id serial primary key,
  content text not null,
  embedding vector(384)
);
