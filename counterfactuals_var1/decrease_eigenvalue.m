function[newm]=decrease_eigenvalue(m,eig_crit,eig_target)

    [VV,DD]=eig(m);
    DD=diag(DD);
    ii=find(DD>eig_crit);
    DD(ii)=eig_target;

newm=real(VV*diag(DD)*pinv(VV));


end