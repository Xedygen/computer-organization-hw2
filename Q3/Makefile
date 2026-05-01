# =========================================================================
# YTU - RISC-V Single-Cycle Processor (Q1)
# Otomatik Simülasyon Makefile
# Kullanım:
# make all    # Simülasyonu çalıştırır ve VCD dosyasını oluşturur
# make wave   # GTKWave ile dalga formunu açar
# make clean  # Üretilen dosyaları temizler
# =========================================================================

IV = iverilog
VVP = vvp
WAVE_VIEWER = gtkwave

SOURCES = alu.v controller.v datapath.v dmem.v extend.v imem.v regfile.v riscv_core.v tb_q3.v
OUT = sim_q3.out
VCD = tb_q3.vcd

all: run

run: $(SOURCES)
	@echo "========================================================"
	@echo "DERLENIYOR..."
	@echo "========================================================"
	$(IV) -o $(OUT) $(SOURCES)
	@echo "Simulasyon calistiriliyor..."
	$(VVP) $(OUT)
	@echo "Simulasyon tamamlandi. Dalga formu: $(VCD)"

wave:
	$(WAVE_VIEWER) $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
