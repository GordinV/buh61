-- Trigger: trigiu_library_before on public.library

--DROP TRIGGER trigi_library_before ON public.library;

CREATE TRIGGER trigu_library_before
  BEFORE UPDATE 
  ON public.library
  FOR EACH ROW
  EXECUTE PROCEDURE public.trigu_library_before();
