local waters = {
    {60, -3000, 0, 3000, -3000, 0, 60, 3000, 0, 3000, 3000, 0},
};

setWaterLevel(-5000);
for i,v in ipairs(waters) do 
    createWater(unpack(v));
end