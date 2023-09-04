

-- Create a table to store your documents
create table documents_by_user (
  id bigserial primary key,
  content text,  -- corresponds to Document.pageContent
  embedding vector(1536),  -- 1536 works for OpenAI embeddings, change if needed
  user_id text
);

-- Create a function to search for documents
create function match_documents_by_user(query_embedding vector(1536), match_count int, user_id text)
returns table(id bigint, content text, similarity float)
language plpgsql
as $$
#variable_conflict use_column
begin
  return query
  select
    id,
    content,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where user_id = user_id
  order by documents.embedding <=> query_embedding
  limit match_count;
end;
$$
;
