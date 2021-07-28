figure();
nmax = 3;
[~,I] = sort(max_ay(:,nspeeds,1),'descend'); %max Ay at max speed
P = unique(P','rows')';
for ii = 1:nmax 
    pos = I(ii);
    disp([ 'Max ' num2str(ii) ': ' num2str(max_ay(pos,nspeeds)) ' G'])
    for jj = 1:nparams
        subplot(nmax,nparams,nparams*(ii-1)+jj)
        c = 1:nparams;
        c(jj) = [];
        [~,ind1] = ismember(P(c,pos)',P(c,:)','rows');
        
        q = ceil(prod(s(jj:end,2))/s(jj,2));
        ind = ((1:s(jj,2))-1)*q+ind1;
        for nn = 1:nspeeds
            plot(cell2mat(sp{jj,2}),max_ay(ind,nn));
            hold on
        end
        plot(P(jj,pos),max_ay(pos,nspeeds),'r.')
        title(sp{jj,1})
        grid on
    end
end
