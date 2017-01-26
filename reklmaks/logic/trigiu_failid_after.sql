-- Trigger: trigiu_library_before on public.library

DROP TRIGGER trigiu_library_before ON public.library;

CREATE TRIGGER trigi_library_before
  BEFORE INSERT 
  ON public.library
  FOR EACH ROW
  EXECUTE PROCEDURE public.trigiu_library_before();
