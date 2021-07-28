function out = emrax207_sat(T, w)

    Pout = T*w;
    Ploss = Pout*.1;
    Pdraw = Pout + Ploss;
    I = 0;
    out = [Pout, I, Pdraw, T, Ploss];

end