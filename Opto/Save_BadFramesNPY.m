function Save_BadFramesNPY(d, i_frs)

i_frs = uint16(i_frs);

%path to python 
py_i_frs = py.numpy.array(i_frs);
%save
save_name = [d,'bad_frames.npy'];
py.numpy.save(save_name, py_i_frs);

end