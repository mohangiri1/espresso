program main_program
    use iso_fortran_env, only: DP => REAL64
    implicit none

    ! Declare variables
    character(len=256) :: filename, output_filename
    complex(DP), allocatable :: evc(:)
    real(DP) :: xk(3)
    integer :: ik, nbnd, ispin, npol, ngw, igwx
    logical :: gamma_only
    integer :: ibnd, default_ibnd, wfcnumber, i
    integer :: start_index, end_index

    ! Initialize loop parameters
    start_index = 1
    end_index = 4  ! Define the end value of wfcnumber
    default_ibnd = 1  ! Default band number

    ! Loop over wavefunction files
    do i = start_index, end_index
        ! Construct filenames
        write(filename, '("wfc", I0, ".dat")') i
        write(output_filename, '("wfc", I0, "_processed.dat")') i

        ! Call the subroutine to read the wavefunction data
        call read_a_wfc(filename, evc, default_ibnd, ik, xk, nbnd, ispin, npol, gamma_only, ngw, igwx)

        ! Output some of the read values for verification
        print *, 'Processing file:', filename
        print *, 'ik:', ik
        print *, 'xk:', xk
        print *, 'nbnd:', nbnd
        print *, 'ispin:', ispin
        print *, 'npol:', npol
        print *, 'gamma_only:', gamma_only
        print *, 'ngw:', ngw
        print *, 'igwx:', igwx

        ! Save all the data to a file
        call save_all_to_file(output_filename, ik, xk, nbnd, ispin, npol, gamma_only, ngw, igwx, evc)

        ! Deallocate the array to free memory
        deallocate(evc)
    end do

contains

    subroutine read_a_wfc(filename, evc, ibnd, ik, xk, nbnd, ispin, npol, gamma_only, ngw, igwx)
        use iso_fortran_env, only: DP => REAL64
        implicit none

        character(len=*), intent(in) :: filename
        complex(DP), intent(out), allocatable :: evc(:)
        real(DP), intent(out) :: xk(3)
        integer, intent(out) :: ik, nbnd, ispin, npol, ngw, igwx
        integer, intent(in) :: ibnd
        integer :: iuni = 1111, i
        real(DP) :: scalef
        real(DP) :: b1(3), b2(3), b3(3), dummy_real
        logical :: gamma_only
        integer :: dummy_int

        ! Open the file
        open(UNIT = iuni, FILE = trim(filename), FORM = 'unformatted', status = 'old')

        ! Read general parameters from the file
        read(iuni) ik, xk, ispin, gamma_only, scalef
        read(iuni) ngw, igwx, npol, nbnd
        read(iuni) b1, b2, b3

        ! Allocate the evc array based on npol and igwx
        allocate(evc(npol * igwx))

        ! Read a dummy integer to skip unwanted data
        read(iuni) dummy_int

        ! Check if the specified ibnd is valid
        if (ibnd > nbnd) then
            print *, 'Error: looking for band nr. ', ibnd, ' but there are only ', nbnd, ' bands in the file'
            close(iuni)
            stop
        end if

        ! Read the wavefunction data
        do i = 1, nbnd
            if (i == ibnd) then
                read(iuni) evc(1:npol * igwx)
                exit
            else
                read(iuni) dummy_real
            end if
        end do

        ! Close the file
        close(iuni)

    end subroutine read_a_wfc

    subroutine save_all_to_file(output_filename, ik, xk, nbnd, ispin, npol, gamma_only, ngw, igwx, evc)
        use iso_fortran_env, only: DP => REAL64
        implicit none

        character(len=*), intent(in) :: output_filename
        integer, intent(in) :: ik, nbnd, ispin, npol, ngw, igwx
        real(DP), intent(in) :: xk(3)
        logical, intent(in) :: gamma_only
        complex(DP), intent(in) :: evc(:)
        integer :: iuni, i

        ! Open the file for writing
        open(UNIT = 20, FILE = trim(output_filename), FORM = 'formatted', STATUS = 'replace')

        ! Write general parameters to the file
        write(20, '(A)', advance='no') 'ik, xk[0], xk[1], xk[2], nbnd, ispin, npol, gamma_only, ngw, igwx'
        write(20, '(I10, F20.10, F20.10, F20.10, I10, I10, I10, L1, I10, I10)', advance='no') &
            ik, xk(1), xk(2), xk(3), nbnd, ispin, npol, gamma_only, ngw, igwx
        write(20, *)
        ! Write wavefunction data header
        write(20, '(A)', advance='no') 'Wavefunction Data (real, imaginary)'
        write(20, *)

        ! Write the wavefunction data
        do i = 1, size(evc)
            write(20, '(F20.10, A, F20.10)', advance='no') real(evc(i)), '    ', aimag(evc(i))
            write(20, *)  ! New line after every numbers
        end do

        ! Close the file
        close(20)

    end subroutine save_all_to_file

end program main_program
