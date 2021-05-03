import matlab.engine
eng = matlab.engine.start_matlab()

eng.cd(r'../mat')

eng.Reconstruction_Romain(nargout=0)
eng.post_process_Romain(nargout=0)
# eng.Compute_AUC(nargout=0)


