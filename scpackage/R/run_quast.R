run_quast = function(filepath, outdir) {
  program = "python /quast-5.0.2/quast.py"
  command = paste0(program, " ", filepath, " -o ", outdir)
  system(command)
}