ktImportText = function(input_files, outfile){
  instring = paste0(input_files, collapse = " ")
  command = paste0("bash /structural_colours/inst/ktImportText.sh -i '", instring, "' -o ", outfile)
  system(command)
}
