# =============================================================
#  RV32I Multi-Cycle CPU  ―  Simulation Makefile (VCS + Verdi)
# =============================================================
#  프로젝트 : RISC-V RV32I 멀티사이클 CPU 코어 + APB 버스 SoC, Basys-3(Artix-7) FPGA 구현
#  구성      : rtl/ (CPU 코어·APB·주변장치·ROM), tb/ (기본 TB + UVM 8만 벡터 검증환경)
#  상세 설명 : README.md 참고 (아키텍처/검증/FPGA 결과/트러블슈팅)
#
#  [ 타겟 사용법 ]
#    make            : generate_f → VCS 컴파일(run) → 시뮬 실행(simv)
#    make generate_f : rtl/tb 소스를 모아 files.f 자동 생성
#    make run        : files.f 로 VCS 컴파일 → build/simv 생성
#    make simv       : 시뮬레이션 실행 (커버리지 line+cond+fsm+tgl+branch+assert, UVM_HIGH)
#    make verdi      : Verdi 로 wave.fsdb 파형 열기
#    make clean      : 빌드/로그/파형 산출물 정리
#
#  [ 요구 환경 ]  Synopsys VCS (UVM 1.2), Verdi  /  FPGA 구현은 Vivado + Basys-3-Master.xdc
#
#  [ 팀 / 역할 ]  3인 팀 프로젝트 (멤버별 fork 운용)
#    - 박정민(본인) : CPU 코어 설계, 누적합 프로그램 기계어 검증, FPGA 온보드 & Negative Slack 해결
#    - 팀원 B       : TODO (APB/주변장치 등)
#    - 팀원 C       : TODO (UVM 검증환경 등)
# =============================================================

# vcs Make file
RTL_DIR   = ./rtl
PKG_DIR   = ./rtl/pkg
TB_DIR    = ./tb
BUILD_DIR = ./build
INC_DIR   = +incdir+$(RTL_DIR)
SIMV_DIR  = ./build/simv
SIMV_OPTS := -cm line+cond+fsm+tgl+branch+assert -cm_dir coverage.vdb -cm_name sim1
SIMV_OPTS += +UVM_VERBOSITY=UVM_HIGH
VCS_OPT   = -full64 -sverilog -debug_access+all -kdb -lca \
            -timescale=1ns/1ps \
            -ntb_opts uvm-1.2 \
            $(INC_DIR) \
            -o $(SIMV_DIR)

all: run simv

generate_f:
	rm -f files.f
	find $(PKG_DIR) \( -name "*.v" -o -name "*.sv" \) | sort >  files.f
	find $(RTL_DIR) -path $(PKG_DIR) -prune -o \
	      \( -name "*.v" -o -name "*.sv" \) -print | sort >> files.f
	find $(TB_DIR)  \( -name "*.v" -o -name "*.sv" \) | sort >> files.f

run: generate_f
	mkdir -p $(BUILD_DIR)
	vcs      $(VCS_OPT) -f files.f

simv:
	$(SIMV_DIR) $(SIMV_OPTS)

verdi:
	verdi -dbdir $(BUILD_DIR)/simv.daidir -ssf wave.fsdb &

clean:
	rm -rf $(BUILD_DIR) csrc novas* ucli.key verdiLog files.f *.fsdb inter.fsdb .inter.fsdb.tbsim sys*

.PHONY: all generate_f run simv verdi clean
